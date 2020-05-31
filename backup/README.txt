# Overview

Each machine backs up files onto its local disk using [Borg][]. Borg's backup
files are copied to strager-nas.

Data flow diagram:

  straglum:/home/strager
    --borg-> straglum:/home/strager/borg-backups/straglum
               --rsync-> strager-nas:/home/strager/borg-backups/straglum

# Extracting backups

1. Install [Borg].
2. Copy files from strager-nas.
2.a. On Windows: `robocopy /e \\strager-nas\homes\strager\borg-backup\straglum c:\users\strager\borg-backup\straglum`
3. Import the key: `borg key import c:\...\straglum c:\...\straglum\exported-borg-key`
4. Find the key's passphrase in your password manager.
5. Find the desired archive and files: `borg list c:\...\straglum ; borg list c:\...\straglum::ARCHIVE_NAME`
6. Extract: `mkdir temp ; cd temp ; borg extract c:\...\straglum::ARCHIVE_NAME`

[Borg]: https://www.borgbackup.org/
