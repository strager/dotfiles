#!/bin/sh

# Exit codes:
# 0 - OK, or destination exists
# 1 - Incorrect usage

if [ "$#" -ne "2" ]; then
    echo "Usage: symlink.sh from to" >&2
    exit 1
fi

FROM="$1"
TO="$2"

if [ -e "$TO" ]; then
    if [ "$(readlink "$TO")" = "$FROM" ]; then
        # Already linked; ignore
        exit 0
    else
        echo "$TO already exists; ignoring" >&2
        exit 0
    fi
fi

# Make $TO's directory if it doesn't exist
TO_DIR="$(dirname "$TO")"
[ "$TO_DIR" != "" ] && mkdir -p -- "$TO_DIR"

# Link!
ln -s -- "$FROM" "$TO"
