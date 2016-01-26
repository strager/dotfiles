#!/bin/sh

set -e -E

HERE="$(cd "$(dirname "${0}")" && pwd)"

/usr/bin/defaults export com.googlecode.iterm2 - \
    >"${HERE}/com.googlecode.iterm2.plist"
