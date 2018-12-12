function! strager#function#function_source_location(function)
  let l:function_var_type = type(a:function)
  if l:function_var_type ==# v:t_string
    let l:function_name = a:function
  elseif l:function_var_type ==# v:t_func
    let l:function_name = get(a:function, 'name')
  else
    throw 'Expected function, but got '.string(a:function)
  endif
  let l:real_function_name = s:real_function_name(l:function_name)
  if l:real_function_name !~# '^\(s:\|[A-Z]\|'."\x80\xfdR".'\|.*#\)'
    " a:function refers to a built-in function.
    return {
      \ 'line': v:none,
      \ 'real_name': l:real_function_name,
      \ 'script_path': v:none,
      \ 'source_name': v:none,
    \ }
  endif
  let l:script_path = s:function_source_script_path(l:real_function_name)
  let l:line = v:none
  let l:source_function_name = v:none
  if l:script_path !=# v:none
    let l:source_function_name = s:source_function_name(l:real_function_name)
    let l:line = s:function_source_line(l:source_function_name, l:script_path)
  endif
  return {
    \ 'line': l:line,
    \ 'real_name': l:real_function_name,
    \ 'script_path': l:script_path,
    \ 'source_name': l:source_function_name,
  \ }
endfunction

function! s:function_source_script_path(real_function_name)
  try
    "" FIXME(strager): Is this the right way to escape the function name?
    let l:function_output = execute('verbose function '.a:real_function_name)
  catch /E123:/
    return v:none
  endtry
  let l:function_info = strager#function#parse_ex_function_output(l:function_output)
  let l:script_path = l:function_info.script_path
  if l:script_path ==# v:none
    throw 'Failed to parse file name for function: '.a:real_function_name
  endif
  return expand(l:script_path, ':p')
endfunction

function! strager#function#parse_ex_function_output(function_output)
  " Example output from :function <name>:
  "
  "    function AlignLine(line, sep, maxpos, extra)
  "         Last set from ~/.vimrc
  " 1    let m = matchlist(a:line, '\(.\{-}\) \{-}\('.a:sep.'.*\)')
  " 2    if empty(m)
  " 3      return a:line
  " 4    endif
  " 5    let spaces = repeat(' ', a:maxpos - strlen(m[1]) + a:extra)
  " 6    return m[1] . spaces . m[2]
  "    endfunction
  let [_, l:last_set_line; _] = split(a:function_output, '\n')
  let l:match = matchlist(l:last_set_line, 'Last set from \(.\{-1,\}\)\%( line \(\d\+\)\)\?$')
  if empty(l:match)
    return {
      \ 'line': v:none,
      \ 'script_path': v:none,
    \ }
  endif
  let [_, l:script_path, l:line_string; _] = l:match
  if l:line_string ==# ''
    let l:line = v:none
  else
    let l:line = str2nr(l:line_string)
  endif
  return {
    \ 'line': l:line,
    \ 'script_path': l:script_path,
  \ }
endfunction

function! s:function_source_line(source_function_name, function_script_path)
  " FIXME(strager): Is this the correct way to escape?
  " FIXME(strager): Use an escaping function from strager#pattern#.
  let l:pattern = '\mfunction!\? '.escape(a:source_function_name, '').'('

  let l:found_line_number = v:none
  let l:cur_line_number = 1
  for l:line in readfile(a:function_script_path)
    if match(l:line, l:pattern) != -1
      let l:found_line_number = l:cur_line_number
    endif
    let l:cur_line_number += 1
  endfor
  return l:found_line_number
endfunction

function! s:source_function_name(real_function_name)
  " <SNR>123_ -> s:
  let l:match = matchlist(a:real_function_name, '^'."\x80\xfd".'R\d\+_\(.\+\)$')
  if !empty(l:match)
    return 's:'.l:match[1]
  endif
  return a:real_function_name
endfunction

function! s:real_function_name(function_name)
  if a:function_name[:4] ==# '<SNR>'
    return "\x80\xfdR".a:function_name[5:]
  endif
  return a:function_name
endfunction
