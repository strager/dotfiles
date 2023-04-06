let s:script_path = expand('<sfile>:p')
let s:script_dir_path = fnamemodify(s:script_path, ':h')

function! Test_gd_is_intelligent_go_to_definition() abort
  call s:set_up_clangd_helper_source()
  " Go to 'foo();'.
  4
  normal 0ff

  normal gd

  " HACK(strager): Wait for ALE and clangd to do their thing.
  sleep 1

  let [l:_buffer_number, l:line, l:column, l:_offset, l:_curswant] = getcurpos()
  call assert_equal(7, l:line)
endfunction

function! s:set_up_clangd_helper_source() abort
  %bwipeout!
  exec 'edit '.fnameescape(s:script_dir_path.'/test_clangd_helper.c')
  setlocal readonly
endfunction

call strager#test#run_all_tests()
