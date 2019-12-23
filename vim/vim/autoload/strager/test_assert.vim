function Test_take_assertion_failure_messages_with_no_asserts() abort
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal([], l:error_messages)
endfunction

function Test_take_assertion_failure_messages_with_assert_report() abort
  call assert_report('test message!')
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal(['test message!'], l:error_messages)
endfunction

function Test_take_assertion_failure_messages_with_many_assert_reports() abort
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

function Test_take_assertion_failure_messages_leaves_no_assertions() abort
  call assert_report('test message')
  call strager#assert#take_assertion_failure_messages()
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal([], l:error_messages)
endfunction

function Test_take_assertion_failure_messages_then_assert_report() abort
  call assert_report('test message 1')
  call strager#assert#take_assertion_failure_messages()
  call assert_report('test message 2')
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal(['test message 2'], l:error_messages)
endfunction

function Test_assert_contains_passes_if_list_contains_string_value_once() abort
  call strager#assert#assert_contains('hello', ['hello'])
  call strager#assert#assert_contains('hello', ['hello', 'world'])
  call strager#assert#assert_contains('hello', ['world', 'hello'])
  call strager#assert#assert_contains('hello', [42, {}, ['hello'], 'hello'])
  call strager#assert#assert_contains([], [[]])
endfunction

function Test_assert_contains_fails_if_list_is_empty() abort
  call strager#assert#assert_contains('hello', [])
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal(["'hello' should be in []"], l:error_messages)
endfunction

function Test_assert_contains_fails_if_list_contains_needle_wrapped_in_list() abort
  call strager#assert#assert_contains('hello', [['hello']])
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal(["'hello' should be in [['hello']]"], l:error_messages)
endfunction

function Test_assert_contains_fails_if_list_contains_equal_value_with_different_type() abort
  " Check sanity.
  call assert_true(0 ==# v:false)
  call assert_notequal(type(0), type(v:false))

  call strager#assert#assert_contains(0, [v:false])
  call strager#assert#assert_contains(v:false, [0])
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal([
    \ '0 should be in [v:false]',
    \ 'v:false should be in [0]',
  \ ], l:error_messages)
endfunction

call strager#test#run_all_tests()
