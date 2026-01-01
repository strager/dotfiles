#!/usr/bin/env python

import contextlib
import datetime
import json
import logging
import os
import pathlib
import platform
import stragerbackup.site
import stragerbackup.util
import subprocess
import sys
import typing
import unittest

logger = logging.getLogger(__name__)


def main() -> None:
    logging.basicConfig(format="%(asctime)s %(message)s", level=logging.INFO)

    site = stragerbackup.site.get_site_for_current_machine()
    logger.info("starting replication for site %s", site.name)

    command = [
        "kopia",
        "--no-progress",
        "repository",
        "sync-to",
        "sftp",
        f"--path={site.nas_sftp_directory}",
        "--host=strager-nas",
        "--username=strager",
        "--keyfile",
        site.ssh_key_file,
        "--known-hosts",
        site.ssh_known_hosts_file,
    ]
    logger.info(f"$ {stragerbackup.util.command_string(command)}")
    subprocess.check_call(command)


if __name__ == "__main__":
    main()
