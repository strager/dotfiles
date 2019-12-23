function! Test_syntax_check_aliases_of_empty_string() abort
  let l:aliases = s:parse_syntax_aliases([''])
  call assert_equal({}, l:aliases)
endfunction

function! Test_syntax_check_aliases_of_one_simple_line() abort
  let l:aliases = s:parse_syntax_aliases([
    \ 'CHECK-ALIAS: c vimLineComment',
  \ ])
  call assert_equal({'c': ['vimLineComment']}, l:aliases)
endfunction

function! Test_syntax_check_aliases_of_one_line_with_surrounding_noise() abort
  let l:aliases = s:parse_syntax_aliases([
    \ '/* CHECK-ALIAS: C javaScriptComment */',
  \ ])
  call assert_equal({'C': ['javaScriptComment']}, l:aliases)
endfunction

function! Test_parse_syntax_check_alias_with_no_groups() abort
  let l:issues = []
  let l:aliases = s:parse_syntax_aliases(['CHECK-ALIAS: /'], l:issues)
  call assert_equal({}, l:aliases)
  call assert_equal([
    \ s:syntax_issue(1, 13, 'Alias code is required'),
  \ ], l:issues)
endfunction

function! Test_syntax_check_aliases_of_one_none_alias() abort
  let l:aliases = s:parse_syntax_aliases([
    \ 'CHECK-ALIAS: / <none>',
  \ ])
  call assert_equal({'/': [v:none]}, l:aliases)
endfunction

function! Test_syntax_check_aliases_of_one_ignore_alias() abort
  let l:aliases = s:parse_syntax_aliases([
    \ 'CHECK-ALIAS: _ <ignore>'
  \ ])
  call assert_equal({'_': v:none}, l:aliases)
endfunction

function! Test_parse_syntax_check_alias_with_space_alias_code() abort
  let l:issues = []
  let l:aliases = s:parse_syntax_aliases([
    \ 'CHECK-ALIAS:   vimLineComment',
  \ ], l:issues)
  call assert_equal({}, l:aliases)
  call assert_equal([
    \ s:syntax_issue(1, 13, 'Alias code is required'),
  \ ], l:issues)
endfunction

function! Test_parse_syntax_check_alias_without_alias_code() abort
  let l:issues = []
  let l:aliases = s:parse_syntax_aliases([
    \ 'CHECK-ALIAS:vimLineComment',
  \ ], l:issues)
  call assert_equal({}, l:aliases)
  call assert_equal([
    \ s:syntax_issue(1, 13, 'Alias code is required'),
  \ ], l:issues)
endfunction

function! Test_parse_syntax_check_alias_with_multiple_choices() abort
  let l:issues = []
  let l:aliases = s:parse_syntax_aliases([
    \ 'CHECK-ALIAS: " vimComment|vimLineComment',
  \ ], l:issues)
  call assert_equal({'"': ['vimComment', 'vimLineComment']}, l:aliases)
  call assert_equal([], l:issues)
endfunction

function! Test_parse_syntax_check_alias_with_multiple_choices_including_none() abort
  let l:issues = []
  let l:aliases = s:parse_syntax_aliases([
    \ 'CHECK-ALIAS: " <none>|vimCommand',
  \ ], l:issues)
  call assert_equal({'"': [v:none, 'vimCommand']}, l:aliases)
  call assert_equal([], l:issues)
endfunction

function! Test_parse_syntax_check_alias_with_multiple_issues() abort
  let l:issues = []
  let l:aliases = s:parse_syntax_aliases([
    \ '',
    \ '// CHECK-ALIAS:',
    \ '// CHECK-ALIAS: x',
    \ '// CHECK-ALIAS: x y',
    \ '/* CHECK-ALIAS: */',
  \ ], l:issues)
  call assert_equal({'x': ['y']}, l:aliases)
  call assert_equal([
    \ s:syntax_issue(2, 16, 'Alias code is required'),
    \ s:syntax_issue(3, 16, 'Alias code is required'),
    \ s:syntax_issue(5, 16, 'Alias code is required'),
  \ ], l:issues)
endfunction

function! Test_parse_syntax_check_alias_with_extra_whitespace() abort
  let l:aliases = s:parse_syntax_aliases([
    \ '  CHECK-ALIAS:  c   vimLineComment   ',
  \ ])
  call assert_equal({'c': ['vimLineComment']}, l:aliases)
endfunction

function! Test_syntax_checks_of_empty_string() abort
  let l:checks = s:parse_syntax_checks([''])
  call assert_equal([], l:checks)
endfunction

function! Test_syntax_checks_of_one_empty_suffix_line() abort
  let l:checks = s:parse_syntax_checks([':CHECK-NEXT-LINE'])
  call assert_equal([
    \ {'line': 2, 'check_string': ''},
  \ ], l:checks)
endfunction

function! Test_syntax_check_line_numbers_of_many_empty_suffix_line() abort
  let l:checks = s:parse_syntax_checks([
    \ '',
    \ ':CHECK-NEXT-LINE',
    \ '',
    \ '',
    \ ':CHECK-NEXT-LINE',
    \ ':CHECK-NEXT-LINE',
    \ '',
  \ ])
  let l:check_lines = map(copy(l:checks), {_, check -> check.line})
  call assert_equal([3, 6, 7], l:check_lines)
endfunction

function! Test_syntax_checks_of_one_suffix_line_with_characters() abort
  let l:checks = s:parse_syntax_checks(['hello world!:CHECK-NEXT-LINE'])
  call assert_equal([
    \ {'line': 2, 'check_string': 'hello world!'},
  \ ], l:checks)
endfunction

function! Test_buffer_issue_quickfix_item_location() abort
  let l:item = s:get_quickfix_item_for_issue(
    \ {'text': 'Missing checks'},
  \ )
  call assert_false(has_key(l:item, 'lnum'))
  call assert_false(has_key(l:item, 'col'))
  call assert_false(has_key(l:item, 'bufnr'))
  call assert_false(has_key(l:item, 'filename'))
  call assert_false(has_key(l:item, 'pattern'))
endfunction

function! Test_syntax_issue_quickfix_item_location() abort
  let l:item = s:get_quickfix_item_for_issue(
    \ s:syntax_issue(5, 3, ''),
  \ )
  call assert_equal(5, l:item.lnum)
  call assert_equal(3, l:item.col)
  call assert_false(has_key(l:item, 'bufnr'))
  call assert_false(has_key(l:item, 'filename'))
  call assert_false(has_key(l:item, 'pattern'))
endfunction

function! Test_syntax_issue_quickfix_item_severity() abort
  let l:item = s:get_quickfix_item_for_issue(
    \ s:syntax_issue(5, 3, ''),
  \ )
  call assert_equal('E', l:item.type)
endfunction

function! Test_syntax_issue_quickfix_item_message() abort
  let l:item = s:get_quickfix_item_for_issue(
    \ s:syntax_issue(5, 3, 'Expected vimCommand but got vimLineComment'),
  \ )
  call assert_equal('Expected vimCommand but got vimLineComment', l:item.text)
endfunction

function! Test_syntax_item_from_current_window_without_syntax() abort
  new
  silent! normal! ihello world
  call assert_equal(v:none, s:syntax_item_from_current_window(1, 1))
endfunction

function! Test_syntax_item_from_current_window_with_vim_syntax() abort
  new
  set filetype=vim
  syntax on
  set paste
  silent! normal! i" This is a comment.
  silent! normal! o
  silent! normal! oset nocompatible " This is a comment.
  call assert_equal('vimLineComment', s:syntax_item_from_current_window(1, 1))
  call assert_equal('vimCommand', s:syntax_item_from_current_window(3, 1))
  call assert_equal('vimOption', s:syntax_item_from_current_window(3, 5))
  call assert_equal('vimComment', s:syntax_item_from_current_window(3, 18))
endfunction

function! s:get_quickfix_item_for_issue(issue) abort
  return strager#check_syntax_internal#get_quickfix_item_for_issue(a:issue)
endfunction

function! s:parse_syntax_aliases(lines, ...) abort
  let l:out_issues = get(a:000, 0, v:none)
  if type(l:out_issues) ==# v:t_none
    let l:issues = []
    let l:aliases = strager#check_syntax_internal#parse_syntax_aliases(
      \ a:lines,
      \ l:issues,
    \ )
    call assert_equal([], l:issues, 'Text should have no check alias issues')
  else
    let l:aliases = strager#check_syntax_internal#parse_syntax_aliases(
      \ a:lines,
      \ l:out_issues,
    \ )
  endif
  return l:aliases
endfunction

function! s:parse_syntax_checks(lines) abort
  return strager#check_syntax_internal#parse_syntax_checks(a:lines)
endfunction

function! s:syntax_item_from_current_window(line, column) abort
  return strager#check_syntax_internal#syntax_item_from_current_window(
    \ a:line,
    \ a:column,
  \ )
endfunction

function! s:syntax_issue(line, column, text) abort
  return {'line': a:line, 'column': a:column, 'text': a:text}
endfunction

call strager#test#run_all_tests()
