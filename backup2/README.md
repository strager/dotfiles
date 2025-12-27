# Backups overview

Each machine backs up files onto its local disk using [Kopia][]. Kopia's
snapshots are copied to a Kopia SFTP repository on strager-nas.

Data flow diagram:

  strapurp:/home/strager
    --kopia-> strapurp:/strapurp-secondary/backups/strager/strapurp/
               --kopia-> strager-nas:/volume2/homes/strager/backups/strapurp

## Client setup for backing up

1. `python -m stragerbackup.create_local`
2. `python -m stragerbackup.replicate`
3. Change the password of the repository on strager-nas.

## Restoration

### Client setup

1. Install [Kopia][].
2. Generate `~/.ssh/id_rsa` if necessary.
3. Add `~/.ssh/id_rsa.pub` to
   `strager@strager-nas:.ssh/authorized_keys`.
4. Update `~/.ssh/known_hosts` by SSH-ing into `strager-nas`
   at least once.
5. Run:
   `kopia repository connect sftp --path=homes/strager/backups/strapurp/ --host=strager-nas --username=strager --keyfile ~/.ssh/id_rsa --known-hosts ~/.ssh/known_hosts`
   * Get the password from your password manager.

### Restore

1. Run `kopia snapshot list --all` and find the desired
   snapshot ID (e.g. `kef78e6a30e2f5c9f2189e6df36ee9279`).
2. Run: `kopia mount kef78e6a30e2f5c9f2189e6df36ee9279`
3. Copy the files from the mounted directory.

Note: If you are low on destination space, [configure Kopia's
cache][Kopia-cache]. Kopia roughly doubles disk usage during restoration due to
its contents cache. For example:
`kopia cache set --content-cache-size-mb=1000 --content-min-sweep-age=10s`

Note: You can use `kopia mount` to explore a snapshot.
However, copying from a mount is very slow. Use
`kopia restore` for mass restoration.

## OS-specific notes

### Linux

Timers are not implemented.

### macOS

The [local.strager.back-up](./local.strager.back-up.plist) launchd service schedules archiving and replication daily. Logs can be found in [/Users/strager/Library/Logs/local.strager.back-up.log]().

```shell
launchctl start local.strager.back-up
tail -f /Users/strager/Library/Logs/local.strager.back-up.log
```

### Windows

The *strager back up 2* Task Schedule job performs archiving and replication daily using the [./staler-back-up.py]() script. Logs can be found in [C:/Users/strager/backups/staler-backup-log.txt]().


[Kopia-cache]: https://kopia.io/docs/advanced/caching/
[Kopia]: https://kopia.io/
