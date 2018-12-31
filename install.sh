#!/bin/sh

set -e -E

if [ "$#" -ne "1" ]; then
    echo "Usage: install.sh \$HOME" >&2
    exit 1
fi

HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="$1"

cd "$HERE"

echo "Symlinking files..."
S="$HERE/symlink.sh"
for project in bash firefox fish fzf git gnome-terminal iterm login nix nixpkgs ssh tmux vim xmonad zsh; do
    echo "($project)"
    HEREP="$HERE/$project"
    . "$HEREP/install.sh"
done

echo "Pulling submodules..."
git submodule --quiet init
git submodule --quiet update
