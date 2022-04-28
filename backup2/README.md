# Backups overview

Each machine backs up files onto its local disk using [Kopia][]. Kopia's
snapshots are copied to a Kopia SFTP repository on strager-nas.

Data flow diagram:

  strapurp:/home/strager
    --kopia-> strapurp:/home/strager/backups/strapurp/
               --kopia-> strager-nas:/volume2/homes/strager/backups/strapurp

## Client setup for backing up

1. `python -m stragerbackup.create_nas`
2. `python -m stragerbackup.create_local`

## Back up

Create snapshot:

    $ kopia snapshot create ~/

Note: ~/.kopiaignore

Copy backups to NAS:

    $ kopia repository sync-to sftp --path=homes/strager/backups/strapurp/ --host=strager-nas --username=strager --keyfile ~/.ssh/id_rsa --known-hosts ~/.ssh/known_hosts

## Client setup for restoration

1. Install [Kopia][].
2. Generate `~/.ssh/id_rsa` if necessary.
3. Add `~/.ssh/id_rsa.pub` to
   `strager@strager-nas:.ssh/authorized_keys`.
4. Update `~/.ssh/known_hosts` by SSH-ing into `strager-nas`
   at least once.
5. Run:
   `kopia repository connect sftp --path=homes/strager/backups/strapurp/ --host=strager-nas --username=strager --keyfile ~/.ssh/id_rsa --known-hosts ~/.ssh/known_hosts`
   * Get the password from your password manager.

## Restore

1. Run `kopia snapshot list --all` and find the desired
   snapshot ID (e.g. `kef78e6a30e2f5c9f2189e6df36ee9279`).
2. Run `kopia restore`. For example:
   `kopia restore --write-files-atomically kef78e6a30e2f5c9f2189e6df36ee9279/Projects/quicklint-js/ restored-quicklint-js`

Note: If you are low on destination space, [configure Kopia's
cache][Kopia-cache]. Kopia roughly doubles disk usage during restoration due to
its contents cache. For example:
`kopia cache set --content-cache-size-mb=1000 --content-min-sweep-age=10s`

Note: You can use `kopia mount all` to explore a snapshot.
However, copying from a mount is very slow. Use
`kopia restore` for mass restoration.

[Kopia-cache]: https://kopia.io/docs/advanced/caching/
[Kopia]: https://kopia.io/
