function! Test_c_identifiers() abort
  %bwipeout!
  set filetype=c
  call s:assert_is_keyword('printf')
  call s:assert_is_keyword('CONSTANT_NAME')
  call s:assert_is_keyword('XMLHttpRequest')
  call s:assert_is_keyword('a1b2c3')
  call s:assert_is_not_keyword('$')
  call s:assert_is_not_keyword('$foobar')
  call s:assert_is_not_keyword('@')
  call s:assert_is_not_keyword('@foobar')
  call s:assert_is_not_keyword('foo-bar')
  call s:assert_is_not_keyword('#define')
endfunction

function! Test_javascript_identifiers() abort
  %bwipeout!
  set filetype=javascript
  call s:assert_is_keyword('console')
  call s:assert_is_keyword('CONSTANT_NAME')
  call s:assert_is_keyword('XMLHttpRequest')
  call s:assert_is_keyword('a1b2c3')
  call s:assert_is_keyword('$')
  call s:assert_is_keyword('$foobar')
  call s:assert_is_not_keyword('@')
  call s:assert_is_not_keyword('@foobar')
  call s:assert_is_not_keyword('foo-bar')
endfunction

function! s:assert_is_keyword(word) abort
  call assert_equal(matchstr(' '.a:word.' ', '\k\+'), a:word)
endfunction

function! s:assert_is_not_keyword(word) abort
  call assert_notequal(matchstr(' '.a:word.' ', '\k\+'), a:word)
endfunction

call strager#test#run_all_tests()
