" Test name structure: prefix.'_'.scenario.'_'.lspstyle.'_'.ctagsstyle
"
" prefix = "Test_go"
" scenario = "function_scenario" or "no_definition_scenario"
" lspstyle = "serverless_lsp" or "working_lsp"
" ctagsstyle = "missing_ctags" or "working_ctags"

function! Test_go_function_scenario_serverless_lsp_missing_ctags() abort
  call s:set_up_function_scenario()
  call s:set_up_serverless_lsp()
  call s:set_up_missing_ctags()
  call s:go()
  call s:assert_error('E433:')
  call s:assert_error('LSP server ".*\<clangd\>.*" is not initialized')
  call s:assert_not_error('No LSP servers found for filetype "c"')
  call s:assert_cursor_should_not_have_jumped()
endfunction

function! Test_go_function_scenario_working_lsp_missing_ctags() abort
  call s:set_up_function_scenario()
  call s:set_up_working_lsp()
  call s:set_up_missing_ctags()
  call s:go()
  call s:assert_no_errors()
  call s:assert_function_scenario_cursor_should_have_jumped()
endfunction

function! Test_go_function_scenario_serverless_lsp_working_ctags() abort
  call s:set_up_function_scenario()
  call s:set_up_serverless_lsp()
  call s:set_up_working_ctags()
  call s:go()
  call s:assert_no_errors()
  call s:assert_function_scenario_cursor_should_have_jumped()
endfunction

function! Test_go_function_scenario_working_lsp_working_ctags() abort
  call s:set_up_function_scenario()
  call s:set_up_working_lsp()
  call s:set_up_working_ctags()
  call s:go()
  call s:assert_no_errors()
  call s:assert_function_scenario_cursor_should_have_jumped()
endfunction

function! Test_go_no_definition_scenario_serverless_lsp_missing_ctags() abort
  call s:set_up_no_definition_scenario()
  call s:set_up_serverless_lsp()
  call s:set_up_missing_ctags()
  call s:go()
  call s:assert_error('E433:')
  call s:assert_error('LSP server ".*\<clangd\>.*" is not initialized')
  call s:assert_cursor_should_not_have_jumped()
endfunction

function! Test_go_no_definition_scenario_working_lsp_missing_ctags() abort
  call s:set_up_no_definition_scenario()
  call s:set_up_working_lsp()
  call s:set_up_missing_ctags()
  call s:go()
  call s:assert_not_error('E433:')
  call s:assert_error('^LSP server ".*\<clangd\>.*" found no definitions$')
  call s:assert_cursor_should_not_have_jumped()
endfunction

function! Test_go_no_definition_scenario_serverless_lsp_working_ctags() abort
  call s:set_up_no_definition_scenario()
  call s:set_up_serverless_lsp()
  call s:set_up_working_ctags()
  call s:go()
  call s:assert_error('^E426:')
  call s:assert_not_error('LSP server ".*\<clangd\>.*" is not initialized')
  call s:assert_cursor_should_not_have_jumped()
endfunction

function! Test_go_no_definition_scenario_working_lsp_working_ctags() abort
  call s:set_up_no_definition_scenario()
  call s:set_up_working_lsp()
  call s:set_up_working_ctags()
  call s:go()
  call s:assert_error('E426:')
  call s:assert_error('LSP server ".*\<clangd\>.*" found no definitions')
  call s:assert_cursor_should_not_have_jumped()
endfunction

let s:script_path = expand('<sfile>:p')
let s:c_helper_path = fnamemodify(s:script_path, ':h').'/test_tag_c_helper.c'

let s:old_cursor_position = v:none

function! s:set_up_function_scenario() abort
  call s:set_up_helper_source()
  " Move the cursor to the 'c' in 'increment(1)'.
  call cursor(8, 12)
  let s:old_cursor_position = getcurpos()
endfunction

function! s:set_up_no_definition_scenario() abort
  call s:set_up_helper_source()
  " Move the cursor to the 'r' in 'return'.
  call cursor(8, 3)
  let s:old_cursor_position = getcurpos()
endfunction

function! s:set_up_helper_source() abort
  new
  exec 'edit '.fnameescape(s:c_helper_path)
endfunction

function! s:set_up_serverless_lsp() abort
  call lsp#disable()
  " HACK(strager): vim-lsp doesn't let us kill the LSP server. Override the
  " existing LSP server configuration. This has a similar effect to killing the
  " LSP server, but the LSP server is still running in the background.
  " HACK(strager): vim-lsp is flaky and sometimes crashes on Linux if the server
  " program exits. Use the 'cat' command which only exits after its standard
  " input is closed.
  let l:Register = {server_name -> lsp#register_server({
    \ 'cmd': {_ -> ['sh', '-c', 'cat >/dev/null']},
    \ 'name': server_name,
    \ 'whitelist': ['c'],
  \ })}
  let l:server_names = lsp#get_server_names()
  if empty(l:server_names)
    call l:Register('clangd')
  else
    for l:server_name in l:server_names
      call l:Register(l:server_name)
    endfor
  endif
endfunction

function! s:set_up_working_lsp() abort
  call lsp#disable()
  " HACK(strager): vim-lsp doesn't always trigger lsp_setup. Make sure clangd is
  " configured by our vimrc. For some reason, this needs to be done with vim-lsp
  " disabled.
  doautocmd User lsp_setup
  call lsp#enable()
  call s:wait_for_lsp()
endfunction

function! s:wait_for_lsp() abort
  let l:timeout_seconds = 5
  let l:start_reltime = reltime()
  while reltimefloat(reltime(l:start_reltime)) < l:timeout_seconds
    for l:server_name in lsp#get_server_names()
      if l:server_name =~# 'clangd'
        \ && !empty(lsp#get_server_capabilities(l:server_name))
        return
      endif
    endfor
    sleep 1m
  endwhile
  throw 'Initializing vim-lsp timed out'
endfunction

function! s:set_up_missing_ctags() abort
  let &tags = ''
endfunction

function! s:set_up_working_ctags() abort
  let l:tags_path = fnamemodify(s:script_path, ':h').'/test_tag_c_helper.c.tags'
  exec 'silent !ctags -f '.shellescape(l:tags_path)
    \ .' '.shellescape(s:c_helper_path)
  let &tags = fnameescape(l:tags_path)
endfunction

let s:go_error = v:none

function! s:go() abort
  let s:go_error = v:none
  try
    call strager#tag#go()
  catch
    let s:go_error = v:exception
  endtry
endfunction

function! s:assert_error(error_pattern) abort
  if s:go_error ==# v:none
    call assert_report('strager#tag#go() should have thrown an exception')
    return
  endif
  call assert_match(a:error_pattern, s:go_error)
endfunction

function! s:assert_not_error(error_pattern) abort
  if s:go_error ==# v:none
    call assert_report('strager#tag#go() should have thrown an exception')
    return
  endif
  call assert_notmatch(a:error_pattern, s:go_error)
endfunction

function! s:assert_no_errors() abort
  if s:go_error !=# v:none
    call assert_report('strager#tag#go() reported an error: '.s:go_error)
    return
  endif
endfunction

function! s:assert_cursor_should_not_have_jumped() abort
  let l:new_cursor_position = getcurpos()
  call assert_equal(s:old_cursor_position, l:new_cursor_position)
endfunction

function! s:assert_function_scenario_cursor_should_have_jumped() abort
  let l:new_cursor_position = getcurpos()
  call assert_equal(s:old_cursor_position[0], l:new_cursor_position[0]) " bufnum
  call assert_equal(3, l:new_cursor_position[1]) " lnum
  call assert_true(count([1, 5], l:new_cursor_position[2])) " col
  call assert_equal(0, l:new_cursor_position[3]) " off
  call assert_true(count([1, 5], l:new_cursor_position[4])) " curswant
  " FIXME(strager): Should we check curswant?
  " TODO(strager): Check that :pop works.
  " TODO(strager): Check that the current window did or didn't change (according
  " to 'switchbuf perhaps?).
endfunction

call strager#test#run_all_tests()
