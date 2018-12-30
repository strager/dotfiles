function! Test_header_is_empty_with_no_headerlines_option()
  let l:options = {
    \ 'options': [],
    \ 'source': ['first', 'second'],
  \ }
  call assert_equal([], strager#fzf#header_lines(l:options))
endfunction

function! Test_header_contains_line_with_header_option()
  let l:options = {
    \ 'options': ['--header=hello'],
    \ 'source': ['first', 'second'],
  \ }
  call assert_equal(['hello'], strager#fzf#header_lines(l:options))
endfunction

function! Test_header_contains_blank_line_with_empty_header_option()
  let l:options = {
    \ 'options': ['--header='],
    \ 'source': ['first', 'second'],
  \ }
  call assert_equal([''], strager#fzf#header_lines(l:options))
endfunction

function! Test_header_contains_first_line_with_headerlines1_option()
  let l:options = {
    \ 'options': ['--header-lines=1'],
    \ 'source': ['first', 'second', 'third'],
  \ }
  call assert_equal(['first'], strager#fzf#header_lines(l:options))
endfunction

function! Test_header_contains_second_word_of_first_line_with_headerlines1_and_withnth2_options()
  let l:options = {
    \ 'options': ['--header-lines=1', '--with-nth=2'],
    \ 'source': ['a first 1', 'b second 2', 'c third 3'],
  \ }
  call assert_equal(['first'], strager#fzf#header_lines(l:options))
endfunction

function! Test_header_contains_first_three_lines_with_headerlines3_option()
  let l:options = {
    \ 'options': ['--header-lines=3'],
    \ 'source': ['first', 'second', 'third', 'fourth', 'fifth'],
  \ }
  call assert_equal(
    \ ['first', 'second', 'third'],
    \ strager#fzf#header_lines(l:options),
  \ )
endfunction

function! Test_presented_lines_includes_all_lines_by_default()
  let l:options = {
    \ 'options': [],
    \ 'source': ['first', 'second'],
  \ }
  call assert_equal(['first', 'second'], strager#fzf#presented_lines(l:options))
endfunction

function! Test_presented_lines_excludes_header_lines()
  let l:options = {
    \ 'options': ['--header=notpresented', '--header-lines=1'],
    \ 'source': ['first', 'second', 'third'],
  \ }
  call assert_equal(['second', 'third'], strager#fzf#presented_lines(l:options))
endfunction

function! Test_presented_lines_includes_only_second_field_with_withnth2()
  let l:options = {
    \ 'options': ['--with-nth=2'],
    \ 'source': ['a first 1', 'b second 2', 'c third 3'],
  \ }
  call assert_equal(
    \ ['first', 'second', 'third'],
    \ strager#fzf#presented_lines(l:options),
  \ )
endfunction

call strager#test#run_all_tests()
