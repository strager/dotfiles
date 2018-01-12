let s:script_path = expand('<sfile>:p')
let s:script_dir_path = fnamemodify(s:script_path, ':h')

function! Test_flow_no_error()
  call s:set_up_no_error_scenario()
  silent make
  call s:assert_cursor_should_not_have_jumped()
endfunction

function! Test_flow_name_error()
  call s:set_up_name_error_scenario()
  silent make
  call s:assert_name_error_scenario_should_have_jumped()
endfunction

let s:old_cursor_position = v:none

function! s:set_up_no_error_scenario()
  call s:set_up_vim()
  call s:set_up_project()
  compiler! flow
  let s:old_cursor_position = getcurpos()
endfunction

function! s:set_up_name_error_scenario()
  call s:set_up_vim()
  call s:set_up_project()
  call system('mv index.js.name_error index.js')
  if v:shell_error != 0
    throw 'Failed to set up index.js for name_error scenario'
  endif
  compiler! flow
  let s:old_cursor_position = getcurpos()
endfunction

function! s:set_up_vim()
  set errorformat=
  set makeprg=
  %bwipeout
endfunction

function! s:set_up_project()
  let l:project_path = tempname()
  call system('rsync -a -- '.shellescape(s:script_dir_path).'/test_js_make_flow_helper/ '.shellescape(l:project_path).'/')
  if v:shell_error != 0
    throw 'Failed to copy project'
  endif
  call system('cd '.shellescape(l:project_path).' && yarn install')
  if v:shell_error != 0
    throw 'Failed to initialize project'
  endif
  cd `=l:project_path`
endfunction

function! s:assert_cursor_should_not_have_jumped()
  let l:new_cursor_position = getcurpos()
  call assert_equal(s:old_cursor_position, l:new_cursor_position)
endfunction

function! s:assert_name_error_scenario_should_have_jumped()
  let l:new_cursor_position = getcurpos()
  let [l:_bufnum, l:lnum, l:col, l:off, l:curswant] = l:new_cursor_position
  call assert_equal(3, l:lnum, 'The cursor should have moved to line 3')
  call assert_equal(9, l:col, 'The cursor should have moved to the beginning of "lof"')
endfunction

call strager#test#run_all_tests()
