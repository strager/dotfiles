function strager#buffer#is_current_buffer_new()
  if bufname('%') ==# ''
    return v:true
  end

  silent file
  let l:match_index = match(v:statusmsg, '\V\[New file\]\|\[Not edited\]')
  if l:match_index !=# -1
    return v:true
  endif

  return v:false
endfunction

function strager#buffer#buffer_number_by_name(name)
  if !bufexists(a:name)
    return -1
  endif
  if a:name ==# '%'
    return bufnr('\%')
  endif
  if a:name ==# '$'
    return bufnr('\$')
  endif
  return bufnr(a:name)
endfunction

function strager#buffer#get_current_buffer_lines()
  return getline('^', '$')
endfunction

function strager#buffer#get_buffer_lines(buffer_number)
  return getbufline(a:buffer_number, '^', '$')
endfunction

function strager#buffer#set_current_buffer_lines(lines)
  normal! ggdG
  call setline(1, a:lines)
endfunction

function strager#buffer#is_quickfix_buffer(buffer_number)
  return getbufvar(a:buffer_number, '&buftype') ==# 'quickfix'
endfunction
