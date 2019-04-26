#!/usr/bin/env zsh

setopt err_exit
setopt pipe_fail
setopt unset

autoload colors

here="$(cd "$(dirname "${0}")" && pwd)"

generate_strager_initialize_menuselect() {
    zmodload zsh/complist

    printf '# WARNING: This file was generated by %s.\n' "$(basename "${ZSH_ARGZERO}")"
    printf '\n'
    printf '# This function is generated to avoid the overhead of loading the\n'
    printf '# zsh/complist module during startup.\n'
    printf 'strager_initialize_menuselect() {\n'
    printf '    bindkey -N menuselect\n'
    bindkey -L -M menuselect | sed -e 's/^/    /'
    printf '}\n'
}

generate_strager_initialize_menuselect >"${here}/strager/strager_initialize_menuselect"