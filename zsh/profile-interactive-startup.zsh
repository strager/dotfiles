#!/usr/bin/env zsh

setopt err_exit
setopt pipe_fail
setopt unset

if ! [[ -o interactive ]]; then
    args=("${SHELL}" -i "${ZSH_SCRIPT}" "${@}")
    printf 'note: re-executing:'
    printf ' %q' "${args[@]}"
    printf '\n'
    exec "${args[@]}"
fi

zmodload zsh/zpty

main() {
    warm_up_zpty
    profile_zsh
    profile_zsh
    profile_zsh
}

run_and_exit_zsh_in_zpty() {
    local name="${1}"
    zpty "${name}" zsh --login -i
    zpty -w "${name}" exit
    zpty -r "${name}" >/dev/null
}

warm_up_zpty() {
    run_and_exit_zsh_in_zpty warmup_zsh
    zpty -d warmup_zsh
}

profile_zsh() {
    local TIMEFMT='%mE elapsed (%mU user, %mS system)'
    time (run_and_exit_zsh_in_zpty zsh)
}

main
