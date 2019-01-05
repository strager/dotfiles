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

_all_test_functions() {
    typeset +f -m 'test_*' | LC_ALL=C sort
}
