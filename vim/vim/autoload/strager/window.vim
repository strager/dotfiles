function! strager#window#is_quickfix_window_open_in_current_tab()
  for l:window_number in range(1, winnr('$'))
    let l:buffer_number = winbufnr(l:window_number)
    if strager#buffer#is_quickfix_buffer(l:buffer_number)
      return v:true
    endif
  endfor
  return v:false
endfunction

function! strager#window#open_quickfix_window()
  let l:window_id = win_getid()
  botright copen
  call win_gotoid(l:window_id)
endfunction
