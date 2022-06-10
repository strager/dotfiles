function! strager#assert#assert_throws(function, error, ...) abort
  let l:msg = get(a:000, 0, v:null)
  try
    call a:function()
    if l:msg ==# v:null
      call assert_report('Function should have thrown an error, but did not')
    else
      call assert_report(l:msg)
    endif
  catch
    if l:msg ==# v:null
      call assert_exception(a:error)
    else
      call assert_exception(a:error, l:msg)
    endif
  endtry
endfunction

function! strager#assert#assert_contains(needle, haystack) abort
  if index(a:haystack, a:needle) == -1
    call assert_report(printf(
      \ '%s should be in %s',
      \ string(a:needle),
      \ string(a:haystack),
    \ ))
  endif
endfunction

function! strager#assert#take_assertion_failure_messages() abort
  let l:errors = v:errors
  let l:error_messages = map(copy(l:errors), {_, error -> matchlist(error, '^[^:]*: \(.*\)$')[1]})
  let v:errors = []
  return l:error_messages
endfunction
