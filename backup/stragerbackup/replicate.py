#!/usr/bin/env python

import datetime
import logging
import stragerbackup.site
import stragerbackup.util
import subprocess

logger = logging.getLogger(__name__)


def main() -> None:
    logging.basicConfig(format="%(message)s", level=logging.INFO)

    site = stragerbackup.site.get_site_for_current_machine()
    timestamp_directory_name = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    # TODO(strager): Periodically perform a --checksum (slow but careful) copy.
    command = [
        "borg",
        "with-lock",
        "--",
        str(site.repository),
        "rsync",
        "--verbose",
        "--links",
        "--one-file-system",
        "--perms",
        "--recursive",
        "--times",
        # Avoid copying cache-like files which can be rebuilt.
        # https://borgbackup.readthedocs.io/en/stable/internals/data-structures.html#index-hints-and-integrity
        "--filter",
        "- /hints.*",
        "--filter",
        "- /index.*",
        # Avoid copying transient lock files.
        # https://borgbackup.readthedocs.io/en/stable/internals/data-structures.html#repository
        "--filter",
        "- /lock.exclusive/",
        "--filter",
        "- /lock.roster",
        # Keep modified and deleted files on the server in case local backups
        # become corrupted. This also keeps copies of Borg's integrity files.
        "--backup",
        f"--backup-dir=../lost+found/{timestamp_directory_name}/",
        "--delete",
        "--",
        str(site.repository) + "/",
        f"strager-nas:borg-backups/{site.name}/",
    ]
    logger.info(f"$ {stragerbackup.util.command_string(command=command)}")
    rsync = subprocess.run(command)
    rsync.check_returncode()


if __name__ == "__main__":
    main()
