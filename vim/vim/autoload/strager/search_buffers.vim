function! strager#search_buffers#search_using_fzf()
  let l:fzf_run_options =
    \ strager#search_buffers#get_fzf_run_options_for_searching_buffers()
  let l:fzf_run_options = fzf#wrap(l:fzf_run_options)
  call fzf#run(l:fzf_run_options)
endfunction

function! strager#search_buffers#get_fzf_run_options_for_searching_buffers()
  let l:current_buffer_name = bufname('%')
  let l:current_buffer_type = strager#buffer#get_buffer_type('%')
  if l:current_buffer_type ==# 'help'
    let l:header = printf('%s [Help]', fnamemodify(l:current_buffer_name, ':t'))
  elseif l:current_buffer_name ==# ''
    let l:header = '[No Name]'
  else
    let l:header = s:pretty_buffer_name(l:current_buffer_name)
  endif

  let l:lines = map(
    \ strager#search_buffers#get_searchable_buffers(),
    \ {_, buffer -> printf('%d %s', buffer.number, buffer.name)},
  \ )

  return {
    \ 'options': ['--delimiter= ', '--header='.l:header, '--with-nth=2..'],
    \ 'sink*': {lines -> s:fzf_sink(lines)},
    \ 'source': l:lines,
  \ }
endfunction

function! strager#search_buffers#get_searchable_buffers()
  let l:directory_buffers = []
  let l:file_buffers = []
  let l:current_buffer_number = bufnr('%')
  let l:last_buffer_number = bufnr('$')
  let l:i = 1
  while l:i <= l:last_buffer_number
    if l:i != l:current_buffer_number
      call s:maybe_add_buffer(l:i, l:file_buffers, l:directory_buffers)
    endif
    let l:i += 1
  endwhile
  call reverse(l:directory_buffers)
  call reverse(l:file_buffers)
  return extend(l:file_buffers, l:directory_buffers)
endfunction

function! s:maybe_add_buffer(buffer_number, out_file_buffers, out_directory_buffers)
  if !bufexists(a:buffer_number)
    return
  endif
  let l:type = strager#buffer#get_buffer_type(a:buffer_number)
  if !(l:type ==# '' || l:type ==# 'nofile')
    return
  endif
  let l:name = bufname(a:buffer_number)
  if l:name ==# ''
    return
  endif
  if s:is_directory_buffer(l:name)
    let l:name = s:pretty_buffer_name(l:name)
    if l:name ==# '.'
      return
    endif
    let l:out_buffers = a:out_directory_buffers
  else
    if !buflisted(a:buffer_number)
      return
    endif
    let l:out_buffers = a:out_file_buffers
  endif
  call add(l:out_buffers, {'name': l:name, 'number': a:buffer_number})
endfunction

function! s:pretty_buffer_name(buffer_name)
  if s:is_directory_buffer(a:buffer_name)
    return s:relative_path(a:buffer_name)
  else
    return a:buffer_name
  endif
endfunction

function! s:fzf_sink(lines)
  if len(a:lines) > 1
    throw 'ES010: Expected exactly zero or one lines'
  endif
  if a:lines ==# []
    return
  endif
  let [l:line] = a:lines
  let [l:_, l:buffer_number_string; l:_] = matchlist(l:line, '^\(\d\+\) ')
  let l:buffer_number = str2nr(l:buffer_number_string)
  execute printf('buffer %s', l:buffer_number)
  if s:is_directory_buffer(bufname('%'))
    " HACK(strager): If we switch to a buffer whose name ends in '/', and there
    " is a 'try' block in the call stack, :buffer does not activate the
    " directory browser. (I suspect this is a bug in Vim.) We could use :silent!
    " buffer to make :buffer do what we want, but :silent! has other effects
    " which we don't want. Explicitly refresh the directory browser so this
    " function behaves as if :buffer did what we wanted it to do.
    call strager#directory_browser#refresh_open_browsers()
  endif
endfunction

function! s:is_directory_buffer(buffer_name)
  return a:buffer_name =~# '/$'
endfunction

function! s:relative_path(path)
  if strager#path#is_relative(a:path)
    return a:path
  endif
  try
    return strager#path#make_relative(getcwd(), a:path)
  catch /^ES004:/
    return a:path
  endtry
endfunction
