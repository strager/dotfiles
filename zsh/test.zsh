#!/usr/bin/env zsh

setopt err_exit
setopt pipe_fail
setopt unset

here="$(cd "$(dirname "${0}")" && pwd)"
"${here}/test_movement.zsh"
"${here}/test_prompt.zsh"
"${here}/test_scm_aliases.zsh"
"${here}/test_sexercism.zsh"
"${PYTHON:-python3}" -m unittest discover --pattern '*.py' --start-directory "${here}" --verbose
