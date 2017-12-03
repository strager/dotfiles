#!/usr/bin/env bash

set -e
set -o pipefail
set -u

run_vim_test() {
    local need_vimrc=false
    local test_script=
    for arg in "${@}"; do
        case "${arg}" in
            --need-vimrc)
                need_vimrc=true
                ;;
            *)
                if [ "${test_script}" = '' ]; then
                    test_script="${arg}"
                else
                    printf '%s: error: unrecognized argument: %s\n' "${0}" "${arg}" >&2
                    return 1
                fi
                ;;
        esac
    done
    if [ "${test_script}" = '' ]; then
        printf '%s: error: missing test script\n' "${0}" >&2
        return 1
    fi

    if ! "${need_vimrc}"; then
        log_and_run vim -N -S "${test_script}" -u NONE
    fi
    log_and_run vim -S "${test_script}"
    return 0
}

log_and_run() {
    local command=("${@}")
    (
        printf '$'
        printf ' %q' "${command[@]}"
        printf '\n'
    ) >&2
    if "${command[@]}"; then
        :
    else
        local status="${?}"
        printf '%s: error: command failed with status %d\n' "${0}" "${status}" >&2
        return "${status}"
    fi
    return 0
}

run_vim_test --need-vimrc vim/vim/autoload/strager/test_tag.vim
run_vim_test --need-vimrc vim/vim/test/test_format.vim
run_vim_test vim/vim/autoload/strager/test_file.vim
run_vim_test vim/vim/autoload/strager/test_path.vim
run_vim_test vim/vim/autoload/strager/test_project.vim
printf 'All tests passed!\n' >&2
