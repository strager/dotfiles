function! strager#quickfix#toggle_quickfix_window() abort
  if strager#quickfix#is_quickfix_window_open()
    cclose
  else
    copen
  endif
endfunction

function! strager#quickfix#is_quickfix_window_open() abort
  for l:buffer in getbufinfo({'bufloaded': v:true})
    if strager#buffer#is_quickfix_buffer(l:buffer.bufnr)
      return !l:buffer.hidden
    endif
  endfor
  return v:false
endfunction
