" Test name structure: prefix.'_'.scenario.'_'.flowstyle
"
" prefix = "Test_go"
" scenario = "function_scenario" or "no_definition_scenario"
" flowstyle = "working_flow" or "no_flow"

" @nocommit test missing .flowconfig

function Test_go_function_scenario_no_flow()
  call s:set_up_function_scenario()
  call s:set_up_no_flow()
  call s:go()
  call s:assert_errors(['E433:'])
  call s:assert_cursor_should_not_have_jumped()
endfunction

function Test_go_function_scenario_working_flow()
  call s:set_up_function_scenario()
  call s:set_up_working_flow()
  call s:go()
  call s:assert_no_errors()
  call s:assert_function_scenario_cursor_should_have_jumped()
endfunction

function Test_go_no_definition_scenario_working_flow()
  call s:set_up_no_definition_scenario()
  call s:set_up_working_flow()
  call s:go()
  call s:assert_errors(['Flow found no definitions'])
  call s:assert_cursor_should_not_have_jumped()
endfunction

let s:script_path = expand('<sfile>:p')
let s:js_helper_path = fnamemodify(s:script_path, ':h').'/test_tag_js_helper.js'

let s:old_cursor_position = v:none

function s:set_up_function_scenario()
  call s:set_up_helper_source()
  " Move the cursor to the 'c' in 'increment(1)'.
  call cursor(8, 15)
  let s:old_cursor_position = getcurpos()
endfunction

function s:set_up_no_definition_scenario()
  call s:set_up_helper_source()
  " Move the cursor to the 'r' in 'return'.
  call cursor(5, 3)
  let s:old_cursor_position = getcurpos()
endfunction

function s:set_up_helper_source()
  %bwipeout!
  let l:project_path = strager#file#make_directory_with_files([])
  new
  exec 'edit '.fnameescape(s:js_helper_path)
  exec 'cd '.fnameescape(l:project_path)
  saveas index.js
endfunction

function s:set_up_no_flow()
endfunction

function s:set_up_working_flow()
  " @nocommit
  silent !yarn init --private --yes
  silent !yarn add --dev flow-bin
  call writefile([], '.flowconfig')
endfunction

" @nocommit dedupe
let s:go_errors = v:none

" @nocommit dedupe
function s:go()
  let s:go_errors = v:none
  let l:messages_before = strager#messages#get_messages()
  call strager#tag#go()
  let s:go_errors = strager#messages#get_new_messages(l:messages_before)
endfunction

" @nocommit dedupe
function s:assert_errors(error_patterns)
  if len(a:error_patterns) < 2
    let l:patterns = a:error_patterns
  elseif len(a:error_patterns) ==# 2
    " @nocommit rename
    let l:format = '\(\(%s\).*\(%s\)\)'
    let l:patterns = [printf(
      \ '%s\|%s',
      \ printf(l:format, a:error_patterns[0], a:error_patterns[1]),
      \ printf(l:format, a:error_patterns[1], a:error_patterns[0]),
    \ )]
  endif
  call strager#assert#assert_matches_unordered(l:patterns, s:go_errors)
endfunction

" @nocommit dedupe
function s:assert_no_errors()
  call assert_equal([], s:go_errors)
endfunction

" @nocommit dedupe
function s:assert_cursor_should_not_have_jumped()
  let l:new_cursor_position = getcurpos()
  call assert_equal(s:old_cursor_position, l:new_cursor_position)
endfunction

" @nocommit dedupe
function! s:assert_function_scenario_cursor_should_have_jumped()
  let l:new_cursor_position = getcurpos()
  call assert_equal(s:old_cursor_position[0], l:new_cursor_position[0]) " bufnum
  call assert_equal(4, l:new_cursor_position[1]) " lnum
  call assert_equal(1, l:new_cursor_position[2]) " col
  call assert_equal(0, l:new_cursor_position[3]) " off
  call assert_equal(1, l:new_cursor_position[4]) " curswant
  " FIXME(strager): Should we check curswant?
  " TODO(strager): Check that :pop works.
  " TODO(strager): Check that the current window did or didn't change (according
  " to 'switchbuf perhaps?).
endfunction

call strager#test#run_all_tests()
