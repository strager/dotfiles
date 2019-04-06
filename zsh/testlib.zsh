assert() {
    local condition=("${@}")
    if ! "${condition[@]}"; then
        {
            printf 'error: assertion failed:'
            printf ' %q' "${condition[@]}"
            printf '\n'
        } >&2
        exit 1
    fi
}

run_all_tests() {
    for test_function in $(_all_test_functions); do
        printf 'Running: %s\n' "${test_function}" >&2
        "${test_function}"
    done
}

force_zsh_interactive() {
    if ! [[ -o interactive ]]; then
        # TODO(strager): Find a proper way to reexec. This looks up zsh in
        # $PATH, which might be different than the currently-running zsh.
        local zsh_executable="${ZSH_NAME}"
        args=("${zsh_executable}" -i "${ZSH_SCRIPT}" "${@}")
        printf 'note: re-executing:'
        printf ' %q' "${args[@]}"
        printf '\n'
        exec "${args[@]}"
    fi
}

_all_test_functions() {
    typeset +f -m 'test_*' | LC_ALL=C sort
}
