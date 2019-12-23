function Test_with_message_fails_if_function_does_not_throw() abort
  call strager#assert#assert_throws(
    \ {-> v:none},
    \ '(some exception)',
    \ 'Empty function should throw (not...)',
  \ )
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal(['Empty function should throw (not...)'], l:error_messages)
endfunction

function Test_without_message_fails_if_function_does_not_throw() abort
  call strager#assert#assert_throws(
    \ {-> v:none},
    \ '(some exception)',
  \ )
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal(['Function should have thrown an error, but did not'], l:error_messages)
endfunction

function Test_with_message_fails_if_function_does_not_throw_matching() abort
  call strager#assert#assert_throws(
    \ {-> s:throw('A test error occurred!')},
    \ 'testing error',
    \ 'Function should throw the right error',
  \ )
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal(["Function should throw the right error: Expected 'testing error' but got 'A test error occurred!'"], l:error_messages)
endfunction

function Test_without_message_fails_if_function_does_not_throw_matching() abort
  call strager#assert#assert_throws(
    \ {-> s:throw('A test error occurred!')},
    \ 'testing error',
  \ )
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal(["Expected 'testing error' but got 'A test error occurred!'"], l:error_messages)
endfunction

function Test_with_message_succeeds_if_function_throws_matching() abort
  call strager#assert#assert_throws(
    \ {-> s:throw('A test error occurred!')},
    \ 'test error',
    \ 'Function should throw the right error',
  \ )
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal([], l:error_messages)
endfunction

function Test_without_message_succeeds_if_function_throws_matching() abort
  call strager#assert#assert_throws(
    \ {-> s:throw('A test error occurred!')},
    \ 'test error',
  \ )
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal([], l:error_messages)
endfunction

function s:throw(error) abort
  throw a:error
endfunction

call strager#test#run_all_tests()
