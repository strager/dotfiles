#!/usr/bin/env bash

set -e
set -o pipefail
set -u

cd "$(dirname "${0}")"

if [ "${VINT:-}" = "" ]; then
  VINT=vint
fi

file_filters=(
    -type f
    \( -name '*.vim' -o -name .vimrc \)
    ! \(
        # Don't lint files from other projects.
        -path '*/external/*'
        -o
        # Don't lint syntax tests. These tests often have
        # invalid or questionable code.
        -path '*/syntax/test_*'
    \)
)
find . "${file_filters[@]}" -print0 \
    | xargs -0 -P8 -n1 "${VINT}"
