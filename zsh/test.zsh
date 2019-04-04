#!/usr/bin/env zsh

setopt err_exit
setopt pipe_fail
setopt unset

here="$(cd "$(dirname "${0}")" && pwd)"
"${here}/test_prompt.zsh"
"${PYTHON:-python3}" -m unittest discover --pattern '*.py' --start-directory "${here}" --verbose
