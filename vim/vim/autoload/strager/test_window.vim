function! Test_quickfix_window_is_not_open() abort
  %bwipeout!
  call assert_false(strager#window#is_quickfix_window_open_in_current_tab())
endfunction

function! Test_quickfix_window_is_open_after_copen() abort
  %bwipeout!
  copen
  call assert_true(strager#window#is_quickfix_window_open_in_current_tab())
endfunction

function! Test_quickfix_window_is_not_open_after_cclose() abort
  %bwipeout!
  copen
  cclose
  call assert_false(strager#window#is_quickfix_window_open_in_current_tab())
endfunction

function! Test_quickfix_window_is_not_after_copen_in_another_tab() abort
  %bwipeout!
  copen
  tabnew
  call assert_false(strager#window#is_quickfix_window_open_in_current_tab())
endfunction

call strager#test#run_all_tests()
