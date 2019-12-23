" TODO(strager): Support default delimiter.

function! Test_header_is_empty_with_no_headerlines_option() abort
  let l:options = {
    \ 'options': ['--delimiter= '],
    \ 'source': ['first', 'second'],
  \ }
  call assert_equal([], strager#fzf#header_lines(l:options))
endfunction

function! Test_header_contains_line_with_header_option() abort
  let l:options = {
    \ 'options': ['--delimiter= ', '--header=hello'],
    \ 'source': ['first', 'second'],
  \ }
  call assert_equal(['hello'], strager#fzf#header_lines(l:options))
endfunction

function! Test_header_contains_blank_line_with_empty_header_option() abort
  let l:options = {
    \ 'options': ['--delimiter= ', '--header='],
    \ 'source': ['first', 'second'],
  \ }
  call assert_equal([''], strager#fzf#header_lines(l:options))
endfunction

function! Test_header_contains_first_line_with_headerlines1_option() abort
  let l:options = {
    \ 'options': ['--delimiter= ', '--header-lines=1'],
    \ 'source': ['first', 'second', 'third'],
  \ }
  call assert_equal(['first'], strager#fzf#header_lines(l:options))
endfunction

function! Test_header_contains_second_word_of_first_line_with_headerlines1_and_withnth2_options() abort
  let l:options = {
    \ 'options': ['--delimiter= ', '--header-lines=1', '--with-nth=2'],
    \ 'source': ['a first 1', 'b second 2', 'c third 3'],
  \ }
  call assert_equal(['first '], strager#fzf#header_lines(l:options))
endfunction

function! Test_header_contains_first_three_lines_with_headerlines3_option() abort
  let l:options = {
    \ 'options': ['--delimiter= ', '--header-lines=3'],
    \ 'source': ['first', 'second', 'third', 'fourth', 'fifth'],
  \ }
  call assert_equal(
    \ ['first', 'second', 'third'],
    \ strager#fzf#header_lines(l:options),
  \ )
endfunction

function! Test_default_field_delimiter_is_not_supported() abort
  let l:options = {
    \ 'options': [],
    \ 'source': ['line'],
  \ }
  call strager#assert#assert_throws(
    \ {-> strager#fzf#presented_lines(l:options)},
    \ 'ES012:',
  \ )
endfunction

function! Test_presented_lines_includes_all_lines_by_default() abort
  let l:options = {
    \ 'options': ['--delimiter= '],
    \ 'source': ['first', 'second'],
  \ }
  call assert_equal(['first', 'second'], strager#fzf#presented_lines(l:options))
endfunction

function! Test_presented_lines_excludes_header_lines() abort
  let l:options = {
    \ 'options': ['--delimiter= ', '--header=notpresented', '--header-lines=1'],
    \ 'source': ['first', 'second', 'third'],
  \ }
  call assert_equal(['second', 'third'], strager#fzf#presented_lines(l:options))
endfunction

function! Test_presented_lines_includes_all_fields_by_default() abort
  let l:options = {
    \ 'options': ['--delimiter= '],
    \ 'source': ['a first 1', 'b second 2', 'c third 3'],
  \ }
  call assert_equal(
    \ ['a first 1', 'b second 2', 'c third 3'],
    \ strager#fzf#presented_lines(l:options),
  \ )
endfunction

function! Test_presented_lines_includes_only_third_field_with_withnth3() abort
  let l:options = {
    \ 'options': ['--delimiter= ', '--with-nth=3'],
    \ 'source': ['a first 1', 'b second 2', 'c third 3'],
  \ }
  call assert_equal(
    \ ['1', '2', '3'],
    \ strager#fzf#presented_lines(l:options),
  \ )
endfunction

function! Test_presented_lines_includes_only_second_field_and_trailing_delimiter_with_withnth2() abort
  let l:options = {
    \ 'options': ['--delimiter= ', '--with-nth=2'],
    \ 'source': ['a first 1', 'b second 2', 'c third 3'],
  \ }
  call assert_equal(
    \ ['first ', 'second ', 'third '],
    \ strager#fzf#presented_lines(l:options),
  \ )
endfunction

function! Test_presented_lines_includes_second_field_and_beyond_with_withnth2dotdot() abort
  let l:options = {
    \ 'options': ['--delimiter= ', '--with-nth=2..'],
    \ 'source': ['one two three four five'],
  \ }
  call assert_equal(
    \ ['two three four five'],
    \ strager#fzf#presented_lines(l:options),
  \ )
endfunction

function! Test_presented_lines_includes_first_field_through_third_field_with_withnthdotdot3() abort
  let l:options = {
    \ 'options': ['--delimiter= ', '--with-nth=..3'],
    \ 'source': ['one two three four five'],
  \ }
  call assert_equal(
    \ ['one two three '],
    \ strager#fzf#presented_lines(l:options),
  \ )
endfunction

function! Test_fields_are_omitted_if_withnth_index_is_out_of_range() abort
  function! s:presented_lines(with_nth) abort
    let l:options = {
      \ 'options': ['--delimiter= ', printf('--with-nth=%s', a:with_nth)],
      \ 'source': ['one two three four five'],
    \ }
    return strager#fzf#presented_lines(l:options)
  endfunction

  call assert_equal([''], s:presented_lines('6'))
  call assert_equal([''], s:presented_lines('6..'))
  call assert_equal(['one two three four five'], s:presented_lines('..7'))
endfunction

function! Test_fields_are_split_with_delimiter_string() abort
  function! s:presented_lines(with_nth) abort
    let l:options = {
      \ 'options': ['--delimiter=,\', printf('--with-nth=%s', a:with_nth)],
      \ 'source': ['a,\b,\c'],
    \ }
    return strager#fzf#presented_lines(l:options)
  endfunction

  call assert_equal(['a,\'], s:presented_lines('1'))
  call assert_equal(['b,\'], s:presented_lines('2'))
endfunction

function! Test_empty_delimiter_makes_one_field_per_character() abort
  function! s:presented_lines(with_nth) abort
    let l:options = {
      \ 'options': ['--delimiter=', printf('--with-nth=%s', a:with_nth)],
      \ 'source': ['abc'],
    \ }
    return strager#fzf#presented_lines(l:options)
  endfunction

  call assert_equal(['a'], s:presented_lines('1'))
  call assert_equal(['b'], s:presented_lines('2'))
endfunction

function! Test_consecutive_delimiters_separate_empty_fields() abort
  function! s:presented_lines(source_line, with_nth) abort
    let l:options = {
      \ 'options': ['--delimiter= ', printf('--with-nth=%s', a:with_nth)],
      \ 'source': [a:source_line],
    \ }
    return strager#fzf#presented_lines(l:options)
  endfunction

  call assert_equal([' '], s:presented_lines('a  b', '2'))
  call assert_equal(['b'], s:presented_lines('a  b', '3'))
  call assert_equal(['a'], s:presented_lines('  a', '3'))
endfunction

function! Test_withnth0_is_invalid() abort
  function! s:presented_lines(with_nth) abort
    let l:options = {
      \ 'options': ['--delimiter= ', printf('--with-nth=%s', a:with_nth)],
      \ 'source': ['line'],
    \ }
    return strager#fzf#presented_lines(l:options)
  endfunction

  call strager#assert#assert_throws({-> s:presented_lines('0')}, 'ES011:')
  call strager#assert#assert_throws({-> s:presented_lines('0..')}, 'ES011:')
  call strager#assert#assert_throws({-> s:presented_lines('..0')}, 'ES011:')
endfunction

function! Test_default_prompt_is_an_arrow() abort
  let l:options = {'options': []}
  call assert_equal('> ', strager#fzf#prompt(l:options))
endfunction

function! Test_prompt_option_sets_prompt() abort
  let l:options = {'options': ['--prompt=[hello]']}
  call assert_equal('[hello]', strager#fzf#prompt(l:options))
endfunction

call strager#test#run_all_tests()
