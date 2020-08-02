#!/usr/bin/env sh
set -e
set -u
exec >>/cygdrive/c/Users/strager/Documents/borg-backups/backup-log.txt 2>&1
printf '\nstarting backup on %s\n' "$(date)"
PATH="${PATH}:/cygdrive/c/Users/strager/Documents/Projects/borg/borg-env/bin/"
cd /cygdrive/c/Users/strager/Documents/Projects/dotfiles/backup
python3 -m stragerbackup.archive
