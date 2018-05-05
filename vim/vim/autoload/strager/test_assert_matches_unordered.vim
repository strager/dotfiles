function Test_extra_strings_fails()
  call strager#assert#assert_matches_unordered(
    \ ['hello world'],
    \ ['hello world', 'extra'],
  \ )
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal([
    \ "Expected 1 strings but got 2: ['hello world', 'extra']",
  \ ], l:error_messages)
endfunction

function Test_missing_strings_fails()
  call strager#assert#assert_matches_unordered(['hello world'], [])
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal(["Expected 1 strings but got 0: []"], l:error_messages)
endfunction

function Test_empty_expected_and_actual_succeeds()
  call strager#assert#assert_matches_unordered([], [])
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal([], l:error_messages)
endfunction

function Test_single_matching_pattern_succeeds()
  call strager#assert#assert_matches_unordered(['hello world'], ['hello world'])
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal([], l:error_messages)
endfunction

function Test_single_nonmatching_pattern_fails()
  call strager#assert#assert_matches_unordered(['hello worlx'], ['hello world'])
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal([
    \ "Pattern 'hello worlx' does not match 'hello world'",
  \ ], l:error_messages)
endfunction

function Test_two_matching_ordered_patterns_succeeds()
  call strager#assert#assert_matches_unordered(
    \ ['hello', 'world'],
    \ ['hello', 'world'],
  \ )
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal([], l:error_messages)
endfunction

function Test_two_matching_swapped_patterns_succeeds()
  call strager#assert#assert_matches_unordered(
    \ ['world', 'hello'],
    \ ['hello', 'world'],
  \ )
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal([], l:error_messages)
endfunction

function Test_only_first_pattern_matching_first_string_fails()
  call strager#assert#assert_matches_unordered(
    \ ['hello', 'worlx'],
    \ ['hello', 'world'],
  \ )
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal([
    \ "Pattern 'worlx' does not match 'world'",
  \ ], l:error_messages)
endfunction

function Test_only_second_pattern_matching_second_string_fails()
  call strager#assert#assert_matches_unordered(
    \ ['hellx', 'world'],
    \ ['hello', 'world'],
  \ )
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal([
    \ "Pattern 'hellx' does not match 'hello'",
  \ ], l:error_messages)
endfunction

function Test_only_first_pattern_matching_second_string_fails()
  call strager#assert#assert_matches_unordered(
    \ ['world', 'hello'],
    \ ['hellx', 'world'],
  \ )
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal(["Pattern 'hello' does not match 'hellx'"], l:error_messages)
endfunction

function Test_only_second_pattern_matching_first_string_fails()
  call strager#assert#assert_matches_unordered(
    \ ['world', 'hello'],
    \ ['hello', 'worlx'],
  \ )
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal(["Pattern 'world' does not match 'worlx'"], l:error_messages)
endfunction

function Test_only_first_pattern_matching_both_fails()
  call strager#assert#assert_matches_unordered(
    \ ['hello', 'world'],
    \ ['hello1', 'hello2'],
  \ )
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal([
    \ "Pattern 'world' does not match 'hello1' or 'hello2'",
  \ ], l:error_messages)
endfunction

function Test_only_second_pattern_matching_both_fails()
  call strager#assert#assert_matches_unordered(
    \ ['hello', 'world'],
    \ ['world1', 'world2'],
  \ )
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal([
    \ "Pattern 'hello' does not match 'world1' or 'world2'",
  \ ], l:error_messages)
endfunction

function Test_both_patterns_matching_only_first_fails()
  call strager#assert#assert_matches_unordered(
    \ ['hel', 'llo'],
    \ ['hello', 'world'],
  \ )
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal([
    \ "Patterns 'hel' and 'llo' do not match 'world'",
  \ ], l:error_messages)
endfunction

function Test_both_patterns_matching_only_second_fails()
  call strager#assert#assert_matches_unordered(
    \ ['wor', 'rld'],
    \ ['hello', 'world'],
  \ )
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal([
    \ "Patterns 'wor' and 'rld' do not match 'hello'",
  \ ], l:error_messages)
endfunction

function Test_first_pattern_matching_both_succeeds()
  call strager#assert#assert_matches_unordered(
    \ ['hello\|world', 'world'],
    \ ['hello', 'world'],
  \ )
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal([], l:error_messages)
endfunction

function Test_second_pattern_matching_both_succeeds()
  call strager#assert#assert_matches_unordered(
    \ ['hello', 'hello\|world'],
    \ ['hello', 'world'],
  \ )
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal([], l:error_messages)
endfunction

function Test_both_patterns_matching_both_succeeds()
  call strager#assert#assert_matches_unordered(
    \ ['hello\|world', 'hello\|world'],
    \ ['hello', 'world'],
  \ )
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal([], l:error_messages)
endfunction

function Test_first_pattern_matching_second_and_second_pattern_matching_both_succeeds()
  call strager#assert#assert_matches_unordered(
    \ ['world', 'hello\|world'],
    \ ['hello', 'world'],
  \ )
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal([], l:error_messages)
endfunction

function Test_first_pattern_matching_both_and_second_pattern_matching_first_succeeds()
  call strager#assert#assert_matches_unordered(
    \ ['hello\|world', 'hello'],
    \ ['hello', 'world'],
  \ )
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal([], l:error_messages)
endfunction

function Test_neither_pattern_matching_fails()
  call strager#assert#assert_matches_unordered(
    \ ['hellx', 'worlx'],
    \ ['hello', 'world'],
  \ )
  let l:error_messages = strager#assert#take_assertion_failure_messages()
  call assert_equal([
    \ "Patterns 'hellx' and 'worlx' do not match 'hello' or 'world'",
  \ ], l:error_messages)
endfunction

function Test_three_patterns_is_not_implemented()
  " TODO(strager): Generalize assert_matches_unordered and delete this test.
  let l:patterns = ['a', 'b', 'c']
  let l:strings = ['a', 'b', 'c']
  call strager#assert#assert_throws(
    \ {-> strager#assert#assert_matches_unordered(l:patterns, l:strings)},
    \ 'not implemented',
  \ )
endfunction

call strager#test#run_all_tests()
