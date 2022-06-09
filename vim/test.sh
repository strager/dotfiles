#!/usr/bin/env bash

set -e
set -o pipefail
set -u

run_vim_syntax_test() {
    local test_script="${1:-}"
    if [ "${test_script}" = '' ]; then
        printf '%s: error: missing test script\n' "${0}" >&2
        return 1
    fi

    local log_file_path="$(mktemp /tmp/vim-test-sh.XXXXXX)"
    local script_args=(
        # Respect mode lines in syntax test files.
        -c 'set modeline'
        -c edit

        -R
        -c 'call strager#check_syntax#check_syntax_and_exit()'
        "${test_script}"
    )
    run_vim_with_log_file "${log_file_path}" "${script_args[@]}"
    return 0
}

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

    local log_file_path="$(mktemp /tmp/vim-test-sh.XXXXXX)"
    local script_args=(
        # Fix some situations where the UI could hang waiting for user input.
        -c 'set nomore'
        -S "${test_script}"
    )
    if ! "${need_vimrc}"; then
        run_vim_with_log_file "${log_file_path}" -N -u NONE "${script_args[@]}"
    fi
    run_vim_with_log_file "${log_file_path}" "${script_args[@]}"
    return 0
}

run_vim_with_log_file() {
    local log_file_path="${1}"
    shift
    local vim_args=("${@}")

    # Clear the log file.
    printf '' >"${log_file_path}"

    # HACK(strager): Prevent Vim from stalling because it's not attached to a
    # terminal.
    vim_args=(--not-a-term "${vim_args[@]}")

    # Log test output to a file. Also, tell the test framework to :cqall! on
    # failure.
    # TODO(strager): Escape the log file properly.
    vim_args+=(--cmd "set verbosefile=${log_file_path}")

    local vim_status=0
    silence_log_and_run vim "${vim_args[@]}" || vim_status="${?}"

    cat "${log_file_path}" >&2
    printf '\n' >&2

    return "${vim_status}"
}

silence_log_and_run() {
    local command=("${@}")
    (
        printf '$'
        printf ' %q' "${command[@]}"
        printf '\n'
    ) >&2
    # HACK(strager): Use 'stall' to trick Vim into thinking an input device is
    # attached. (If Vim thinks it can never receive more input, and Vim ever
    # polls for input, Vim exits abruptly.)
    # HACK(strager): Redirect stdout and stderr to avoid duplicate output (once
    # from Vim's stderr and once from the log file).
    if stall | "${command[@]}" >/dev/null 2>&1; then
        :
    else
        local status="${?}"
        printf '%s: error: command failed with status %d\n' "${0}" "${status}" >&2
        return "${status}"
    fi
    return 0
}

stall() {
    zsh -c 'zmodload zsh/zselect; zselect -r 1 -e 1'
}

run_vim_syntax_test vim/vim/syntax/test_cpp/boolean.cpp
run_vim_syntax_test vim/vim/syntax/test_cpp/comment.cpp
run_vim_syntax_test vim/vim/syntax/test_cpp/macro.cpp
run_vim_syntax_test vim/vim/syntax/test_cpp/type.cpp
run_vim_syntax_test vim/vim/syntax/test_dirvish/dirvish
run_vim_syntax_test vim/vim/syntax/test_javascript/boolean.js
run_vim_syntax_test vim/vim/syntax/test_javascript/control.js
run_vim_syntax_test vim/vim/syntax/test_javascript/function.js
run_vim_syntax_test vim/vim/syntax/test_javascript/module.js
run_vim_syntax_test vim/vim/syntax/test_javascript/number.js
run_vim_syntax_test vim/vim/syntax/test_javascript/string.js
run_vim_syntax_test vim/vim/syntax/test_javascript/template.js
run_vim_syntax_test vim/vim/syntax/test_javascript/var.js
run_vim_syntax_test vim/vim/syntax/test_objdump/conceal.objdump
run_vim_syntax_test vim/vim/syntax/test_objdump/disassembly.objdump
run_vim_syntax_test vim/vim/syntax/test_objdump/symbol_header.objdump
run_vim_syntax_test vim/vim/syntax/test_objdump/x86_64.objdump
run_vim_syntax_test vim/vim/syntax/test_vim/bracket.vim
run_vim_syntax_test vim/vim/syntax/test_vim/command.vim
run_vim_syntax_test vim/vim/syntax/test_vim/misc.vim
run_vim_syntax_test vim/vim/syntax/test_vim/number.vim
run_vim_syntax_test vim/vim/syntax/test_vim/operator.vim
run_vim_syntax_test vim/vim/syntax/test_vim/pattern.vim
run_vim_syntax_test vim/vim/syntax/test_vim/statement.vim
run_vim_syntax_test vim/vim/syntax/test_vim/string.vim
run_vim_syntax_test vim/vim/syntax/test_vim/user_function.vim
run_vim_syntax_test vim/vim/syntax/test_vim/variable.vim
run_vim_test --need-vimrc vim/vim/autoload/strager/test_directory_browser.vim
run_vim_test --need-vimrc vim/vim/autoload/strager/test_search_buffers.vim
run_vim_test --need-vimrc vim/vim/autoload/strager/test_syntax.vim
run_vim_test --need-vimrc vim/vim/test/test_CVE-2019-12735.vim
run_vim_test --need-vimrc vim/vim/test/test_c_make_ninja.vim
run_vim_test --need-vimrc vim/vim/test/test_clipboard.vim
run_vim_test --need-vimrc vim/vim/test/test_color_column.vim
run_vim_test --need-vimrc vim/vim/test/test_directory_browser.vim
run_vim_test --need-vimrc vim/vim/test/test_format.vim
run_vim_test --need-vimrc vim/vim/test/test_grep.vim
run_vim_test --need-vimrc vim/vim/test/test_identifier.vim
run_vim_test --need-vimrc vim/vim/test/test_indentation.vim
run_vim_test --need-vimrc vim/vim/test/test_tab.vim
run_vim_test vim/vim/autoload/strager/test_assert.vim
run_vim_test vim/vim/autoload/strager/test_assert_throws.vim
run_vim_test vim/vim/autoload/strager/test_buffer.vim
run_vim_test vim/vim/autoload/strager/test_check_syntax.vim
run_vim_test vim/vim/autoload/strager/test_check_syntax_internal.vim
run_vim_test vim/vim/autoload/strager/test_cxx_symbol.vim
run_vim_test vim/vim/autoload/strager/test_exception.vim
run_vim_test vim/vim/autoload/strager/test_file.vim
run_vim_test vim/vim/autoload/strager/test_file_sort.vim
run_vim_test vim/vim/autoload/strager/test_function.vim
run_vim_test vim/vim/autoload/strager/test_fzf.vim
run_vim_test vim/vim/autoload/strager/test_list.vim
run_vim_test vim/vim/autoload/strager/test_messages.vim
run_vim_test vim/vim/autoload/strager/test_move_file.vim
run_vim_test vim/vim/autoload/strager/test_path.vim
run_vim_test vim/vim/autoload/strager/test_pattern.vim
run_vim_test vim/vim/autoload/strager/test_random_mt19937.vim
run_vim_test vim/vim/autoload/strager/test_search_files.vim
run_vim_test vim/vim/autoload/strager/test_window.vim
printf 'All tests passed!\n' >&2
