#!/usr/bin/env zsh

setopt err_exit
setopt pipe_fail
setopt unset

here="$(cd "$(dirname "${0}")" && pwd)"
. "${here}/testlib.zsh"

# TODO(strager): Move into ~/.zshenv.
fpath=("${here}/strager" "${fpath[@]}")
autoload -Uk strager_deduplicate_history_lines

test_unique_lines_are_preserved() {
    local input=$' 1235  second command\n 1234  first command\n'
    local actual=
    deduplicate_history_lines "${input}" actual
    assert [ "${actual}" = "${input}" ]
}

test_only_newest_adjacent_duplicate_is_preserved() {
    local actual=
    deduplicate_history_lines $' 4444  last command\n 3333  duplicated command\n 2222  duplicated command\n 1111  first command\n' actual
    assert [ "${actual}" = $' 4444  last command\n 3333  duplicated command\n 1111  first command\n' ]
}

test_same_commands_differing_by_foreign_flag_are_deduplicated() {
    local actual=
    deduplicate_history_lines $' 3333  duplicated command\n 2222* duplicated command\n' actual
    assert [ "${actual}" = $' 3333  duplicated command\n' ]
    deduplicate_history_lines $' 3333* duplicated command\n 2222  duplicated command\n' actual
    assert [ "${actual}" = $' 3333* duplicated command\n' ]
}

test_same_commands_differing_in_number_width_are_deduplicated() {
    local actual=
    deduplicate_history_lines $'99999  duplicated command\n    1  duplicated command\n' actual
    assert [ "${actual}" = $'99999  duplicated command\n' ]
    deduplicate_history_lines $'123456789  duplicated command\n   42  duplicated command\n' actual
    assert [ "${actual}" = $'123456789  duplicated command\n' ]
}

test_only_newest_distant_duplicate_is_preserved() {
    local actual=
    deduplicate_history_lines $' 4444  last command\n 3333  duplicated command\n 2222  other command\n 1111  duplicated command\n' actual
    assert [ "${actual}" = $' 4444  last command\n 3333  duplicated command\n 2222  other command\n' ]
}

deduplicate_history_lines() {
    local dhl_history_lines="${1}"
    local dhl_output_variable="${2}"

    local dhl_deduplicated="$(strager_deduplicate_history_lines <<<"${dhl_history_lines}")"$'\n'
    eval "$(printf '%s=%q' "${dhl_output_variable}" "${dhl_deduplicated}")"
}

run_all_tests
