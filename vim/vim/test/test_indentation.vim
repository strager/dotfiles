function! Test_gtgt_indents_line_by_shiftwidth_spaces() abort
  %bwipeout!
  setlocal expandtab shiftwidth=5
  normal! ihello
  normal! >>
  call assert_equal(['     hello'], strager#buffer#get_current_buffer_lines())
endfunction

function! Test_ctrlt_in_insert_mode_indents_line_by_shiftwidth_spaces() abort
  %bwipeout!
  setlocal expandtab shiftwidth=5
  execute "normal! ihello\<C-T>"
  call assert_equal(['     hello'], strager#buffer#get_current_buffer_lines())
endfunction

function! Test_leading_tab_in_insert_mode_indents_line_by_shiftwidth_spaces() abort
  %bwipeout!
  setlocal expandtab shiftwidth=5
  execute "normal! i\<Tab>hello"
  call assert_equal(['     hello'], strager#buffer#get_current_buffer_lines())
endfunction

call strager#test#run_all_tests()
