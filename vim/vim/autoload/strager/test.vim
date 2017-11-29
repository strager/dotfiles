function! strager#test#run_all_tests()
  redir @">
  function /^Test_/
  redir END
  let l:function_lines = split(@", '\n')
  let l:function_names = map(
    \ l:function_lines,
    \ {_, s -> substitute(s, '^function \(.\{-}\)(.*$', '\1', '')})
  if len(l:function_names) == 0
    echoerr 'No Test_ functions found'
    return
  endif
  call strager#test#run_tests(l:function_names)
endfunction

function! strager#test#run_tests(test_function_names)
  let l:failed_test_function_names = []
  " NOTE(strager): Emulate the output of Google Test's console reporter. This
  " lets us clearly see which test have which errors, for example.
  " See: https://github.com/google/googletest/
  echomsg '[==========] Running '.len(a:test_function_names).' tests'
  for l:test_function_name in a:test_function_names
    let v:errors = []
    try
      echomsg '[ RUN      ] '.l:test_function_name
      call funcref(l:test_function_name)()
    catch
      call add(v:errors, v:exception)
    endtry
    if len(v:errors) == 0
      echomsg '[       OK ] '.l:test_function_name
    else
      " TODO(strager): Make these errors print synchronously.
      for l:error in v:errors
        echoerr l:error
      endfor
      echomsg '[  FAILED  ] '.l:test_function_name
      call add(l:failed_test_function_names, l:test_function_name)
    endif
  endfor
  echomsg '[==========] '.len(a:test_function_names).' tests ran.'
  echomsg '[  PASSED  ] '.len(a:test_function_names).' tests.'
  if len(l:failed_test_function_names) == 0
    " Quit Vim so developer iteration is faster.
    qall!
  else
    echomsg '[  FAILED  ] '.len(l:failed_test_function_names)
      \ .' tests, listed below:'
    for l:test_function_name in l:failed_test_function_names
      echomsg '[  FAILED  ] '.l:test_function_name
    endfor
    " Leave Vim alive so errors can be inspected by a human.
    " TODO(strager): Log to a file and :cquit!?
  endif
endfunction
