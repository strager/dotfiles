function! Test_toggling_quickfix_opens() abort
  cclose

  call strager#quickfix#toggle_quickfix_window()

  call assert_true(strager#buffer#is_quickfix_buffer(bufnr('%')))
  call assert_true(strager#quickfix#is_quickfix_window_open())
endfunction

function! Test_toggling_quickfix_closes() abort
  copen

  call strager#quickfix#toggle_quickfix_window()

  call assert_false(strager#quickfix#is_quickfix_window_open())
endfunction

function! Test_focused_quickfix_window_is_open() abort
  copen
  call assert_true(strager#buffer#is_quickfix_buffer(bufnr('%')))

  call assert_true(strager#quickfix#is_quickfix_window_open())
endfunction

function! Test_unfocused_quickfix_window_is_open() abort
  copen
  vsplit somefile
  call assert_false(strager#buffer#is_quickfix_buffer(bufnr('%')))

  call assert_true(strager#quickfix#is_quickfix_window_open())
endfunction

function! Test_quickfix_window_is_not_open() abort
  copen
  cclose

  call assert_false(strager#quickfix#is_quickfix_window_open())
endfunction

call strager#test#run_all_tests()
