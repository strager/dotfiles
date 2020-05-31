#!/usr/bin/env python

import contextlib
import datetime
import json
import logging
import os
import pathlib
import pipes
import platform
import stragerbackup.borg
import stragerbackup.site
import subprocess
import sys
import typing
import unittest

logger = logging.getLogger(__name__)


def main() -> None:
    logging.basicConfig(format="%(message)s", level=logging.INFO)

    site = stragerbackup.site.get_site_for_current_machine()

    archives = stragerbackup.borg.get_borg_archives(
        repository=site.repository,
        key_file=site.archive_key_file,
        key_passphrase_file=site.archive_key_passphrase_file,
    )
    last_slow_backup = find_last_slow_backup(archives)
    do_slow_backup = False
    if last_slow_backup is None:
        logger.info("Found no slow backups")
        do_slow_backup = True
    else:
        last_slow_backup_age = datetime.datetime.now() - last_slow_backup.time
        logger.info(
            f"Last slow backup was {last_slow_backup.name} at {last_slow_backup.time} ({last_slow_backup_age} ago)"
        )
        if last_slow_backup_age >= site.slow_backup_frequency:
            logger.info(f"Last slow backup is older than {site.slow_backup_frequency}")
            do_slow_backup = True

    if do_slow_backup:
        logger.info("Performing slow backup")
    else:
        logger.info("Performing fast backup")
    back_up(
        repository=site.repository,
        patterns_file=site.patterns_file,
        key_file=site.archive_key_file,
        key_passphrase_file=site.archive_key_passphrase_file,
        slow=do_slow_backup,
    )


def back_up(
    repository: pathlib.Path,
    patterns_file: pathlib.Path,
    key_file: pathlib.Path,
    key_passphrase_file: pathlib.Path,
    slow: bool,
) -> None:
    archive_name = f"straglum-{'slow' if slow else 'fast'}-{int(datetime.datetime.now().timestamp())}"
    process = stragerbackup.borg.run_borg_command(
        command=[
            "borg",
            "create",
            "--files-cache",
            "rechunk,ctime" if slow else "ctime,size,inode",
            "--one-file-system",
            "--patterns-from",
            str(patterns_file),
            # Show useful diagnostics.
            "--info",
            "--show-version",
            "--stats",
            # Save space and time.
            "--noatime",
            "--nobsdflags",
            f"{repository}::{archive_name}",
        ],
        key_file=key_file,
        passphrase_file=key_passphrase_file,
    )
    process.check_returncode()


def find_last_slow_backup(
    archives: typing.List[stragerbackup.borg.BorgArchive],
) -> typing.Optional[stragerbackup.borg.BorgArchive]:
    result = None
    for archive in archives:
        if "-slow-" in archive.name:
            result = archive
    return result


class TestArchives(unittest.TestCase):
    def test_last_slow_backup_with_no_archives(self) -> None:
        borg_list_output = {
            "archives": [],
            "encryption": {"mode": "repokey"},
            "repository": {
                "id": "ef8340e47e75d41df2187a162c1d3f6fb5e7f8e3ea3df697b009fcf5a3109518",
                "last_modified": "2020-05-29T20:48:37.000000",
                "location": "/home/strager/Projects/backup/emptyrepo",
            },
        }
        archive = find_last_slow_backup(
            stragerbackup.borg.parse_borg_list_output(borg_list_output)
        )
        self.assertIsNone(archive)

    def test_last_slow_backup_with_fast_backups(self) -> None:
        borg_list_output = {
            "archives": [
                {
                    "archive": "straglum-fast-Projects-1590635697",
                    "barchive": "straglum-fast-Projects-1590635697",
                    "id": "d57f9155d39473952775d6b9a307af179263165f5c1829418faca37a5ee31b37",
                    "name": "straglum-fast-Projects-1590635697",
                    "start": "2020-05-28T03:14:57.000000",
                    "time": "2020-05-28T03:14:57.000000",
                },
                {
                    "archive": "straglum-fast-Projects-1590798244",
                    "barchive": "straglum-fast-Projects-1590798244",
                    "id": "3a60ffe8cf1e58b37c728fcb2ced6911e829f3835917a6f04d8481097afee0d9",
                    "name": "straglum-fast-Projects-1590798244",
                    "start": "2020-05-30T00:24:05.000000",
                    "time": "2020-05-30T00:24:05.000000",
                },
            ],
            "encryption": {
                "keyfile": "/home/strager/.config/borg/keys/home_strager_borg_backups_straglum.10",
                "mode": "keyfile-blake2",
            },
            "repository": {
                "id": "d5e6040419033dad150d582bd11d7d0c632d35cb01ea0772c67e60a3c9315d8f",
                "last_modified": "2020-05-30T00:30:28.000000",
                "location": "/home/strager/borg-backups/straglum",
            },
        }
        archive = find_last_slow_backup(
            stragerbackup.borg.parse_borg_list_output(borg_list_output)
        )
        self.assertIsNone(archive)

    def test_last_slow_backup_with_slow_backups(self) -> None:
        borg_list_output = {
            "archives": [
                {
                    "archive": "straglum-slow-Projects-1590635697",
                    "barchive": "straglum-slow-Projects-1590635697",
                    "id": "d57f9155d39473952775d6b9a307af179263165f5c1829418faca37a5ee31b37",
                    "name": "straglum-slow-Projects-1590635697",
                    "start": "2020-05-28T03:14:57.000000",
                    "time": "2020-05-28T03:14:57.000000",
                },
                {
                    "archive": "straglum-slow-Projects-1590798244",
                    "barchive": "straglum-slow-Projects-1590798244",
                    "id": "3a60ffe8cf1e58b37c728fcb2ced6911e829f3835917a6f04d8481097afee0d9",
                    "name": "straglum-slow-Projects-1590798244",
                    "start": "2020-05-30T00:24:05.000000",
                    "time": "2020-05-30T00:24:05.000000",
                },
            ],
            "encryption": {
                "keyfile": "/home/strager/.config/borg/keys/home_strager_borg_backups_straglum.10",
                "mode": "keyfile-blake2",
            },
            "repository": {
                "id": "d5e6040419033dad150d582bd11d7d0c632d35cb01ea0772c67e60a3c9315d8f",
                "last_modified": "2020-05-30T00:30:28.000000",
                "location": "/home/strager/borg-backups/straglum",
            },
        }
        archive = find_last_slow_backup(
            stragerbackup.borg.parse_borg_list_output(borg_list_output)
        )
        self.assertIsNotNone(archive)
        self.assertEqual(archive.name, "straglum-slow-Projects-1590798244")
        self.assertEqual(
            archive.time,
            datetime.datetime(year=2020, month=5, day=30, hour=0, minute=24, second=5),
        )
        self.assertEqual(archive.time.tzinfo, datetime.datetime.now().tzinfo)


if __name__ == "__main__":
    main()
