#!/usr/bin/env python

import contextlib
import datetime
import json
import logging
import os
import pathlib
import pipes
import platform
import stat
import stragerbackup.site
import stragerbackup.util
import subprocess
import sys
import tempfile
import typing
import unittest

logger = logging.getLogger(__name__)


def main() -> None:
    logging.basicConfig(format="%(asctime)s %(message)s", level=logging.INFO)

    site = stragerbackup.site.get_site_for_current_machine()
    logger.info("starting backup for site %s", site.name)

    check_kopiaignore(site=site)

    if sys.platform == 'win32':
        script_base = pathlib.Path(__file__).parent
        before_script = script_base / "windows-snapshot-before.ps1"
        after_script = script_base / "windows-snapshot-after.ps1"
        logger.info(f"configuring snapshot actions: {before_script} and {after_script}")
        # FIXME(strager): We should do proper escaping here.
        subprocess.check_call(["kopia", "policy", "set", site.backed_up_directory, "--before-folder-action", f'powershell -WindowStyle Hidden -File "{before_script}"'])
        subprocess.check_call(["kopia", "policy", "set", site.backed_up_directory, "--after-folder-action", f'powershell -WindowStyle Hidden -File "{after_script}"'])

    command = ["kopia", "--no-progress", "snapshot", "create", "--force-enable-actions", "--", site.backed_up_directory]
    logger.info(f"$ {stragerbackup.util.command_string(command)}")
    subprocess.check_call(command)


def check_kopiaignore(site: stragerbackup.site.Site) -> None:
    backup_ignore_file = pathlib.Path(site.backed_up_directory, ".kopiaignore")
    if backup_ignore_file.is_symlink():
        logger.error(
            "file %s is a symlink, which Kopia does not support; not backing up",
            backup_ignore_file,
        )
        exit(1)

    source_ignore_file = site.source_ignore_file.resolve()
    expected_ignore_data = source_ignore_file.read_bytes()
    if backup_ignore_file.exists():
        if backup_ignore_file.read_bytes() != expected_ignore_data:
            logger.error(
                "file %s is out of sync with %s; copying from %s",
                backup_ignore_file,
                source_ignore_file,
                source_ignore_file,
            )
            copy = True
        else:
            copy = False
    else:
        logger.info(
            "file %s does not exist; copying from %s",
            backup_ignore_file,
            source_ignore_file,
        )
        copy = True
    if copy:
        atomic_write_read_only_file(backup_ignore_file, expected_ignore_data)


def atomic_write_read_only_file(path: pathlib.Path, content: bytes) -> None:
    """Atomically create or overwrite a file. The file is marked as read-only.

    This function does not respect file permissions of the original file. If a file at 'path' exists, and is read-only, it is overwritten anyway.

    If 'path' refers to a symlink, it is not followed.
    """
    with tempfile.TemporaryDirectory() as temp_dir:
        temp_path = pathlib.Path(temp_dir) / "temp"
        temp_path.write_bytes(content)
        os.chmod(temp_path, stat.S_IREAD | stat.S_IRGRP | stat.S_IROTH)
        if sys.platform == 'win32':
            # HACK(strager): Avoid ERROR_ACCESS_DENIED from SetRenameInformationFile() if the destination is read-only.
            os.chmod(path, os.stat(path).st_mode | stat.S_IWRITE)
        temp_path.replace(path)


if __name__ == "__main__":
    main()
