#!/usr/bin/env sh
set -e
set -u

printf '\n\nstarting backup %s\n' "$(date)" >&2

cd "$(dirname "${0}")"
PATH="${HOME}/.nix-profile/bin:${PATH}"
python3 -m stragerbackup.archive
python3 -m stragerbackup.replicate
