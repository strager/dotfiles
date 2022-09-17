function! Test_cycle_format_lower() abort
  %bwipeout!
  normal! ihello_world

  normal \-
  call assert_equal('helloWorld', getline('.'))

  normal \-
  call assert_equal('hello_world', getline('.'))
endfunction

function! Test_cycle_format_upper() abort
  %bwipeout!
  normal! iHelloWorld

  normal \-
  call assert_equal('Hello_World', getline('.'))

  normal \-
  call assert_equal('HELLO_WORLD', getline('.'))

  normal \-
  call assert_equal('HelloWorld', getline('.'))
endfunction

call strager#test#run_all_tests()
