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
