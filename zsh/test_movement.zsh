#!/usr/bin/env zsh

setopt err_exit
setopt pipe_fail
setopt unset

here="$(cd "$(dirname "${0}")" && pwd)"
. "${here}/testlib.zsh"

# TODO(strager): Move into ~/.zshenv.
fpath=("${here}/strager" "${fpath[@]}")
autoload -Uk strager_move_backward_shortword

test_moving_backward_shortword_from_beginning_does_nothing() {
    assert [ "$(search_backward_shortword '' 0 )" -eq 0 ]
    assert [ "$(search_backward_shortword 'hello' 0 )" -eq 0 ]
}

test_moving_backward_shortword_inside_first_word_moves_to_beginning() {
    assert [ "$(search_backward_shortword 'a' 1 )" -eq 0 ]
    assert [ "$(search_backward_shortword 'abc' 1 )" -eq 0 ]
    assert [ "$(search_backward_shortword 'abc' 2 )" -eq 0 ]
    assert [ "$(search_backward_shortword 'abc' 3 )" -eq 0 ]
}

test_moving_backward_shortword_inside_word_moves_to_beginning_of_word() {
    assert [ "$(prefix_after_backward_shortword 'abc def' 5 )" = 'abc ' ]
    assert [ "$(prefix_after_backward_shortword 'abc def' 6 )" = 'abc ' ]
    assert [ "$(prefix_after_backward_shortword 'abc ***' 6 )" = 'abc ' ]
}

test_moving_backward_shortword_at_beginning_of_word_moves_to_beginning_of_previous_word() {
    assert [ "$(prefix_after_backward_shortword 'abc def ghi' 8 )" = 'abc ' ]
    assert [ "$(prefix_after_backward_shortword 'abc   def   ghi' 12 )" = 'abc   ' ]
}

test_moving_backward_shortword_skips_whitespace() {
    assert [ "$(prefix_after_backward_shortword '  abc' 1 )" = '' ]
    assert [ "$(prefix_after_backward_shortword '  abc' 2 )" = '' ]
    assert [ "$(prefix_after_backward_shortword 'abc def    ' 8 )" = 'abc ' ]
}

test_moving_backward_shortword_skips_letters_to_hit_symbol() {
    assert [ "$(prefix_after_backward_shortword 'echo ${PATH}' 9 )" = 'echo ${' ]
    assert [ "$(prefix_after_backward_shortword 'echo "hello"' 9 )" = 'echo "' ]
}

test_moving_backward_shortword_skips_some_symbols_as_letters() {
    assert [ "$(prefix_after_backward_shortword 'echo readme.txt' 15 )" = 'echo ' ]
    assert [ "$(prefix_after_backward_shortword 'echo abc_def' 12 )" = 'echo ' ]
    assert [ "$(prefix_after_backward_shortword 'echo abc-def' 12 )" = 'echo ' ]
}

test_moving_backward_shortword_skips_symbols_to_hit_letter() {
    assert [ "$(prefix_after_backward_shortword 'echo hello${' 12 )" = 'echo hello' ]
    assert [ "$(prefix_after_backward_shortword 'echo ${hello}' 13 )" = 'echo ${hello' ]
    assert [ "$(prefix_after_backward_shortword 'echo hello**' 12 )" = 'echo hello' ]
}

# NOTE(strager): '/' is a special case. Vim's 'b' motion has no analog to this.
test_moving_backward_shortword_skips_letters_after_skipping_slash() {
    assert [ "$(prefix_after_backward_shortword 'echo one/' 9 )" = 'echo ' ]
    assert [ "$(prefix_after_backward_shortword 'echo one/two/' 13 )" = 'echo one/' ]
    assert [ "$(prefix_after_backward_shortword 'echo /one/' 10 )" = 'echo /' ]
}

test_moving_backward_shortword_stops_between_whitespace_and_slash() {
    assert [ "$(prefix_after_backward_shortword 'echo /' 6 )" = 'echo ' ]
    assert [ "$(prefix_after_backward_shortword 'echo / ' 7 )" = 'echo ' ]
}

test_moving_backward_shortword_skips_letters_to_hit_slash() {
    assert [ "$(prefix_after_backward_shortword 'path/to/file' 12 )" = 'path/to/' ]
}

test_moving_backward_shortword_skips_symbols_to_hit_slash() {
    assert [ "$(prefix_after_backward_shortword 'path/**' 7 )" = 'path/' ]
}

test_moving_backward_shortword_skips_consecutive_slashes() {
    assert [ "$(prefix_after_backward_shortword '////' 4 )" = '' ]
}

test_moving_backward_shortword_skips_whitespace_before_skipping_slash() {
    assert [ "$(prefix_after_backward_shortword 'path/to/ ' 9 )" = 'path/' ]
}

prefix_after_backward_shortword() {
    local buffer="${1}"
    local cursor_before="${2}"
    local cursor_after="$(search_backward_shortword "${buffer}" "${cursor_before}")"
    printf '%s' "${buffer[0, ${cursor_after}]}"
}

search_backward_shortword() {
    local BUFFER="${1}"
    local CURSOR="${2}"
    strager_move_backward_shortword
    printf '%d' "${CURSOR}"
}

run_all_tests
