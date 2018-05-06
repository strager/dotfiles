function Test_take_assertion_failure_messages_with_no_asserts()
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal([], l:error_messages)
endfunction

function Test_take_assertion_failure_messages_with_assert_report()
  call assert_report('test message!')
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal(['test message!'], l:error_messages)
endfunction

function Test_take_assertion_failure_messages_with_many_assert_reports()
  call assert_report('test message 1')
  call assert_report('test message 2')
  call assert_report('test message 3')
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal([
    \ 'test message 1',
    \ 'test message 2',
    \ 'test message 3',
  \ ], l:error_messages)
endfunction

function Test_take_assertion_failure_messages_leaves_no_assertions()
  call assert_report('test message')
  call strager#assert#take_assertion_failure_messages()
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal([], l:error_messages)
endfunction

function Test_take_assertion_failure_messages_then_assert_report()
  call assert_report('test message 1')
  call strager#assert#take_assertion_failure_messages()
  call assert_report('test message 2')
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal(['test message 2'], l:error_messages)
endfunction

call strager#test#run_all_tests()
