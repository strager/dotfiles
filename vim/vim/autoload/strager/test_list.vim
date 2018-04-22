function Test_new_messages_of_empty_lists()
  call assert_equal([], strager#list#new_messages([], []))
endfunction

function Test_new_messages_with_equal_lists()
  call assert_equal([], strager#list#new_messages(
    \ ['hello', 'world'],
    \ ['hello', 'world'],
  \ ))
endfunction

function Test_new_messages_after_append()
  call assert_equal(['list item'], strager#list#new_messages([], ['list item']))
  call assert_equal(['world'], strager#list#new_messages(
    \ ['hello'],
    \ ['hello', 'world'],
  \ ))
  call assert_equal(['d', 'e'], strager#list#new_messages(
    \ ['a', 'b', 'c'],
    \ ['a', 'b', 'c', 'd', 'e'],
  \ ))
endfunction

function Test_new_messages_after_clear()
  call assert_equal([], strager#list#new_messages(['old', 'messages'], []))
endfunction

function Test_new_messages_after_clear_then_append()
  call assert_equal(['new'], strager#list#new_messages(['old'], ['new']))
  call assert_equal(['new'], strager#list#new_messages(
    \ ['old', 'messages'],
    \ ['new'],
  \ ))
  call assert_equal(['new', 'messages'], strager#list#new_messages(
    \ ['old', 'messages'],
    \ ['new', 'messages'],
  \ ))
  call assert_equal(['a', 'b', 'c', 'd'], strager#list#new_messages(
    \ ['old', 'messages'],
    \ ['a', 'b', 'c', 'd'],
  \ ))
endfunction

function Test_new_messages_after_pop_then_append()
  call assert_equal(['b'], strager#list#new_messages(['a'], ['b']))
  call assert_equal(['c'], strager#list#new_messages(['a', 'b'], ['b', 'c']))
  call assert_equal(['e'], strager#list#new_messages(
    \ ['a', 'b', 'c', 'd'],
    \ ['b', 'c', 'd', 'e'],
  \ ))
  call assert_equal(['x'], strager#list#new_messages(
    \ ['x', 'y', 'x', 'y'],
    \ ['y', 'x', 'y', 'x'],
  \ ))
  call assert_equal(['x'], strager#list#new_messages(
    \ ['y', 'x', 'x', 'x'],
    \ ['x', 'x', 'x', 'x'],
  \ ))
endfunction

function Test_new_messages_after_2_pops_then_appends()
  call assert_equal(['c', 'd'], strager#list#new_messages(
    \ ['a', 'b'],
    \ ['c', 'd'],
  \ ))
  call assert_equal(['d', 'e'], strager#list#new_messages(
    \ ['a', 'b', 'c'],
    \ ['c', 'd', 'e'],
  \ ))
  call assert_equal(['z', 'w'], strager#list#new_messages(
    \ ['x', 'y', 'x', 'y'],
    \ ['x', 'y', 'z', 'w'],
  \ ))
endfunction

function Test_new_messages_after_3_pops_then_appends()
  call assert_equal(['f', 'g', 'h'], strager#list#new_messages(
    \ ['a', 'b', 'c', 'd', 'e'],
    \ ['d', 'e', 'f', 'g', 'h'],
  \ ))
endfunction

call strager#test#run_all_tests()
