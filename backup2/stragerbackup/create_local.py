#!/usr/bin/env python

import contextlib
import datetime
import json
import logging
import os
import pathlib
import pipes
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
    logger.info("creating local repository for site %s", site.name)

    command = [
        "kopia",
        "repository",
        "create",
        "filesystem",
        "--path",
        site.local_directory,
    ]
    logger.info(f"$ {stragerbackup.util.command_string(command)}")
    subprocess.check_call(command)


if __name__ == "__main__":
    main()
