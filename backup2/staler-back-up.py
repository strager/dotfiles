#!/usr/bin/env python3
import datetime
import os
import pathlib
import subprocess
import sys

with open("c:/Users/strager/backups/staler-backup-log.txt", "a") as log:
    log.write(f"\nstarting backup on {datetime.datetime.now()}\n")
    log.flush()

    os.chdir(pathlib.Path(__file__).parent)
    subprocess.run([sys.executable, "-m", "stragerbackup.archive"], check=True, stdout=log, stderr=log)
    subprocess.run([sys.executable, "-m", "stragerbackup.replicate"], check=True, stdout=log, stderr=log)
