function Test_check_vim_syntax_with_no_checks_fails()
  call s:set_up_vim_window_with_no_syntax_checks()
  let l:buffer_number = bufnr('%')

  call strager#check_syntax#check_syntax()
  let l:quickfix_info = getqflist({'all': v:true})
  let l:items = l:quickfix_info.items
  call assert_equal(1, len(l:items))
  call assert_equal('Missing checks', l:items[0].text)
  call assert_equal(l:buffer_number, l:items[0].bufnr)
endfunction

function s:set_up_vim_window_with_no_syntax_checks()
  new
endfunction

function Test_check_vim_syntax_with_no_errors_creates_empty_quickfix_list()
  call s:set_up_vim_window_with_no_syntax_check_errors()
  let l:quickfix_info_before = getqflist({'all': v:true})
  call strager#check_syntax#check_syntax()
  let l:quickfix_info_after = getqflist({'all': v:true})
  call assert_equal([], l:quickfix_info_after.items)
  call assert_notequal(l:quickfix_info_before.id, l:quickfix_info_after.id)
endfunction

function s:set_up_vim_window_with_no_syntax_check_errors()
  new
  set filetype=vim
  syntax on
  set paste
  silent! normal i" CHECK-ALIAS: " <none>
  silent! normal o" CHECK-ALIAS: c vimCommand
  silent! normal o" CHECK-ALIAS: f vimUserFunc
  silent! normal o" CHECK-ALIAS: ( vimParenSep
  silent! normal o" CHECK-ALIAS: ) vimParenSep
  silent! normal o" cccc fff():CHECK-NEXT-LINE
  silent! normal o  call foo()
endfunction

function Test_check_syntax_with_check_alias_issues()
  call s:set_up_window_with_check_alias_issues()
  let l:buffer_number = bufnr('%')

  let l:quickfix_info_before = getqflist({'all': v:true})
  call strager#check_syntax#check_syntax()
  let l:quickfix_info_after = getqflist({'all': v:true})
  call assert_notequal(l:quickfix_info_before.id, l:quickfix_info_after.id)

  let l:items = l:quickfix_info_after.items
  call assert_equal(2, len(l:items))
  call assert_equal(
    \ 'Alias code is required',
    \ l:items[0].text,
  \ )
  call assert_equal(
    \ 'Alias code is required',
    \ l:items[1].text,
  \ )
  call assert_equal(1, l:items[0].lnum)
  call assert_equal(13, l:items[0].col)
  call assert_equal(2, l:items[1].lnum)
  call assert_equal(16, l:items[1].col)
  for l:quickfix_item in l:items
    call assert_equal(l:buffer_number, l:quickfix_item.bufnr)
    call assert_true(l:quickfix_item.valid)
  endfor
endfunction

function s:set_up_window_with_check_alias_issues()
  new
  syntax on
  set paste
  silent! normal iCHECK-ALIAS:
  silent! normal o-- CHECK-ALIAS: asdfasdf
  silent! normal o:CHECK-NEXT-LINE
  silent! normal o
endfunction

function Test_check_vim_syntax_with_errors_creates_quickfix_list()
  call s:set_up_vim_window_with_syntax_check_errors()
  let l:buffer_number = bufnr('%')

  let l:quickfix_info_before = getqflist({'all': v:true})
  call strager#check_syntax#check_syntax()
  let l:quickfix_info_after = getqflist({'all': v:true})
  call assert_notequal(l:quickfix_info_before.id, l:quickfix_info_after.id)

  let l:items = l:quickfix_info_after.items
  call assert_equal(2, len(l:items))
  call assert_equal(
    \ 'Expected vimUserFunc but got vimCommand',
    \ l:items[0].text,
  \ )
  call assert_equal(
    \ 'Expected vimCommand but got vimUserFunc',
    \ l:items[1].text,
  \ )
  call assert_equal(7, l:items[0].lnum)
  call assert_equal(3, l:items[0].col)
  call assert_equal(7, l:items[1].lnum)
  call assert_equal(8, l:items[1].col)
  for l:quickfix_item in l:items
    call assert_equal(l:buffer_number, l:quickfix_item.bufnr)
    call assert_true(l:quickfix_item.valid)
  endfor
endfunction

function Test_check_vim_syntax_with_errors_moves_cursor_to_first_issue()
  call s:set_up_vim_window_with_syntax_check_errors()
  1
  call strager#check_syntax#check_syntax()
  let [l:_bufnum, l:lnum, l:col, l:_off, l:_curswant] = getcurpos()
  call assert_equal({'line': 7, 'column': 3}, {'line': l:lnum, 'column': l:col})
endfunction

function s:set_up_vim_window_with_syntax_check_errors()
  new
  set filetype=vim
  syntax on
  set paste
  silent! normal i" CHECK-ALIAS: " <none>
  silent! normal o" CHECK-ALIAS: c vimCommand
  silent! normal o" CHECK-ALIAS: f vimUserFunc
  silent! normal o" CHECK-ALIAS: ( vimParenSep
  silent! normal o" CHECK-ALIAS: ) vimParenSep
  silent! normal o" fccc cff():CHECK-NEXT-LINE
  silent! normal o  call foo()
endfunction

function Test_check_syntax_with_no_checks()
  let l:issues = []
  call s:check_syntax_generic({
    \ 'aliases': {},
    \ 'checks': [],
    \ 'get_syntax_item': {line, column -> v:none},
  \ }, l:issues)
  call assert_equal([], l:issues)
endfunction

function Test_check_syntax_with_only_ignore_checks()
  let l:issues = []
  call s:check_syntax_generic({
    \ 'aliases': {},
    \ 'checks': [{'line': 1, 'check_string': '   '}],
    \ 'get_syntax_item': {line, column ->
      \ [v:none, 'vimLineComment', 'vimCommand'][column - 1]
    \ },
  \ }, l:issues)
  call assert_equal([], l:issues)
endfunction

function Test_check_syntax_with_only_aliased_ignore_checks()
  let l:issues = []
  call s:check_syntax_generic({
    \ 'aliases': {'_': v:none},
    \ 'checks': [{'line': 1, 'check_string': '___'}],
    \ 'get_syntax_item': {line, column ->
      \ [v:none, 'vimLineComment', 'vimCommand'][column - 1]
    \ },
  \ }, l:issues)
  call assert_equal([], l:issues)
endfunction

function Test_check_syntax_with_undefined_aliases()
  let l:issues = []
  call s:check_syntax_generic({
    \ 'aliases': {},
    \ 'checks': [{'line': 1, 'check_string': 'x y'}],
    \ 'get_syntax_item': {line, column -> v:none},
  \ }, l:issues)
  call assert_equal([
    \ s:syntax_issue(1, 1, 'Unspecified alias code: x'),
    \ s:syntax_issue(1, 3, 'Unspecified alias code: y'),
  \ ], l:issues)
endfunction

function Test_check_syntax_with_failing_positive_check()
  let l:issues = []
  call s:check_syntax_generic({
    \ 'aliases': {'c': ['vimLineComment']},
    \ 'checks': [{'line': 1, 'check_string': 'c'}],
    \ 'get_syntax_item': {line, column -> v:none},
  \ }, l:issues)
  call assert_equal([
    \ s:syntax_issue(1, 1, 'Expected vimLineComment but got <none>'),
  \ ], l:issues)
endfunction

function Test_check_syntax_with_passing_positive_check()
  let l:issues = []
  call s:check_syntax_generic({
    \ 'aliases': {'c': ['vimLineComment']},
    \ 'checks': [{'line': 1, 'check_string': 'c'}],
    \ 'get_syntax_item': {line, column -> 'vimLineComment'},
  \ }, l:issues)
  call assert_equal([], l:issues)
endfunction

function Test_check_syntax_with_failing_negative_check()
  let l:issues = []
  call s:check_syntax_generic({
    \ 'aliases': {'_': [v:none]},
    \ 'checks': [{'line': 1, 'check_string': '_'}],
    \ 'get_syntax_item': {line, column -> 'vimLineComment'},
  \ }, l:issues)
  call assert_equal([
    \ s:syntax_issue(1, 1, 'Expected <none> but got vimLineComment'),
  \ ], l:issues)
endfunction

function Test_check_syntax_with_passing_negative_check()
  let l:issues = []
  call s:check_syntax_generic({
    \ 'aliases': {'_': [v:none]},
    \ 'checks': [{'line': 1, 'check_string': '_'}],
    \ 'get_syntax_item': {line, column -> v:none},
  \ }, l:issues)
  call assert_equal([], l:issues)
endfunction

function Test_check_syntax_with_many_passing_negative_checks()
  let l:issues = []
  call s:check_syntax_generic({
    \ 'aliases': {'_': [v:none]},
    \ 'checks': [{'line': 1, 'check_string': '____'}],
    \ 'get_syntax_item': {line, column -> v:none},
  \ }, l:issues)
  call assert_equal([], l:issues)
endfunction

function Test_check_syntax_with_failing_adjacent_positive_checks()
  let l:issues = []
  call s:check_syntax_generic({
    \ 'aliases': {'c': ['vimLineComment']},
    \ 'checks': [{'line': 1, 'check_string': 'cccc'}],
    \ 'get_syntax_item': {line, column ->
      \ [v:none, v:none, 'vimLineComment', 'vimLineComment'][column - 1]
    \ },
  \ }, l:issues)
  call assert_equal([
    \ s:syntax_issue(1, 1, 'Expected vimLineComment but got <none>'),
    \ s:syntax_issue(1, 2, 'Expected vimLineComment but got <none>'),
  \ ], l:issues)
endfunction

function Test_no_syntax_mismatches_for_ignored_lines()
  let l:issues = []
  call s:check_syntax_generic({
    \ 'aliases': {'c': ['vimCommand']},
    \ 'checks': [{'line': 2, 'check_string': 'cccc'}],
    \ 'get_syntax_item': {line, column -> [
      \ ['vimLineComment', 'vimLineComment', 'vimLineComment'],
      \ ['vimCommand', 'vimCommand', 'vimCommand', 'vimCommand'],
      \ ['vimCommand', v:none, 'vimLineComment'],
    \ ][line - 1][column - 1]},
  \ }, l:issues)
  call assert_equal([], l:issues)
endfunction

function Test_syntax_mismatches_on_third_line()
  let l:issues = []
  call s:check_syntax_generic({
    \ 'aliases': {'c': ['vimCommand'], '/': ['vimLineComment']},
    \ 'checks': [{'line': 3, 'check_string': 'c//'}],
    \ 'get_syntax_item': {line, column -> [
      \ ['vimLineComment', 'vimLineComment', 'vimLineComment'],
      \ ['vimCommand', 'vimCommand', 'vimCommand', 'vimCommand'],
      \ ['vimCommand', v:none, 'vimLineComment'],
    \ ][line - 1][column - 1]},
  \ }, l:issues)
  call assert_equal([
    \ s:syntax_issue(3, 2, 'Expected vimLineComment but got <none>'),
  \ ], l:issues)
endfunction

function Test_alias_with_alternatives_matches_all_alternatives()
  let l:issues = []
  call s:check_syntax_generic({
    \ 'aliases': {'c': ['vimComment', 'vimLineComment']},
    \ 'checks': [{'line': 1, 'check_string': 'ccc'}],
    \ 'get_syntax_item': {line, column ->
      \ ['vimComment', 'vimComment', 'vimLineComment'][column - 1]
    \ },
  \ }, l:issues)
  call assert_equal([], l:issues)
endfunction

function Test_alias_with_alternatives_fails_match()
  let l:issues = []
  call s:check_syntax_generic({
    \ 'aliases': {'c': ['vimComment', 'vimLineComment']},
    \ 'checks': [{'line': 1, 'check_string': 'ccc'}],
    \ 'get_syntax_item': {line, column ->
      \ ['vimCommand', v:none, 'vimLineComment'][column - 1]
    \ },
  \ }, l:issues)
  call assert_equal([
    \ s:syntax_issue(
      \ 1,
      \ 1,
      \ 'Expected vimComment or vimLineComment but got vimCommand',
    \ ),
    \ s:syntax_issue(
      \ 1,
      \ 2,
      \ 'Expected vimComment or vimLineComment but got <none>',
    \ ),
  \ ], l:issues)
endfunction

function s:check_syntax_generic(options, out_issues)
  return strager#check_syntax#check_syntax_generic(a:options, a:out_issues)
endfunction

function s:syntax_issue(line, column, text)
  return {'line': a:line, 'column': a:column, 'text': a:text}
endfunction

call strager#test#run_all_tests()
