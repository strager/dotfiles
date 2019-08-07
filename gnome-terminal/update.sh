#!/bin/sh

set -e -E

HERE="$(cd "$(dirname "${0}")" && pwd)"

/usr/bin/dconf dump /org/gnome/terminal/ >"${HERE}/gnome-terminal.ini"
