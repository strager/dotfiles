function strager#list#new_messages(before, after) abort
  for l:i in range(len(a:before))
    let l:comparison_length = min([len(a:before) - l:i, len(a:after)])
    if s:sublists_are_equal(a:before, l:i, a:after, 0, l:comparison_length)
      return a:after[len(a:before) - l:i:]
    endif
  endfor
  return a:after
endfunction

function s:sublists_are_equal(list_a, list_a_start, list_b, list_b_start, comparison_length) abort
  for l:offset in range(0, a:comparison_length - 1)
    let l:index_a = a:list_a_start + l:offset
    let l:index_b = a:list_b_start + l:offset
    if a:list_a[l:index_a] !=# a:list_b[l:index_b]
      return v:false
    endif
  endfor
  return v:true
endfunction
