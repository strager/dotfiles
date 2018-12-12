function! strager#directory_browser#refresh_open_browsers()
  let l:old_buffer_number = bufnr('%')
  try
    for l:buffer in getbufinfo({'bufloaded': v:true})
      let l:filetype = getbufvar(l:buffer.bufnr, '&filetype')
      if l:filetype ==# 'dirvish'
        call s:refresh_open_browser(l:buffer.bufnr)
      endif
    endfor
  finally
    " FIXME(strager): Does this change the scroll position or have other side
    " effects?
    execute printf('buffer %d', l:old_buffer_number)
  endtry
endfunction

function! s:refresh_open_browser(buffer_number)
  execute printf('buffer %d', a:buffer_number)
  Dirvish %
endfunction

function! strager#directory_browser#prompt_delete_file_under_cursor()
  let l:line = getline('.')
  " FIXME(strager): Handle when l:line is empty (e.g. if the browsed directory
  " is empty).
  call strager#directory_browser#prompt_delete_file(l:line)
endfunction

function! strager#directory_browser#prompt_delete_file(path)
  let l:response = input(printf('Delete %s? [yN] ', a:path))
  if l:response ==# 'y'
    call delete(a:path)
    call strager#directory_browser#refresh_open_browsers()
  endif
endfunction

function strager#directory_browser#register_commands()
  command -complete=dir -nargs=1 BrowserMkdir
    \ call <SID>browser_mkdir_command(<q-args>)
endfunction

function! s:browser_mkdir_command(path)
  call strager#file#mkdirp(a:path)
  call strager#directory_browser#refresh_open_browsers()
  " TODO(strager): Move the cursor only if the current buffer is a browser.
  call s:move_cursor_to_entry_if_possible(a:path)
endfunction

function! s:move_cursor_to_entry_if_possible(path)
  let l:absolute_path = resolve(a:path)
  let l:browser_path = resolve(bufname('%'))
  try
    let l:relative_path = strager#path#make_relative(
      \ l:browser_path,
      \ l:absolute_path,
    \ )
  catch /^ES004:/
    return
  endtry
  let l:path_in_browser = strager#path#components(l:relative_path)[0]
  call search(strager#pattern#from_string(l:path_in_browser), 'cw')
endfunction
