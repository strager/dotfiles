function! strager#directory_browser#refresh_open_browsers() abort
  " FIXME(strager): refresh_open_browsers seems to cause buffers to hide
  " spuriously. For now, let's disable the feature.
  return

  let l:old_tab_number = tabpagenr()
  try
    execute "tabdo windo normal \<c-l>"
  finally
    execute printf('%dtabnext', l:old_tab_number)
    " TODO(strager): Shouldn't we restore the current window too?
  endtry
endfunction

function! strager#directory_browser#prompt_delete_file_under_cursor() abort
  let l:line = getline('.')
  " FIXME(strager): Handle when l:line is empty (e.g. if the browsed directory
  " is empty).
  call strager#directory_browser#prompt_delete_file(l:line)
endfunction

function! strager#directory_browser#prompt_delete_file(path) abort
  let l:response = input(printf('Delete %s? [yN] ', a:path))
  if l:response ==# 'y'
    call delete(a:path)
    call strager#directory_browser#refresh_open_browsers()
  endif
endfunction

function! strager#directory_browser#register_commands() abort
  command -complete=dir -nargs=1 BrowserMkdir
    \ call <SID>browser_mkdir_command(<q-args>)
  command -nargs=0 BrowserUp
    \ call <SID>browser_up_command()
endfunction

function! s:browser_mkdir_command(path) abort
  call strager#file#mkdirp(a:path)
  call strager#directory_browser#refresh_open_browsers()
  " TODO(strager): Move the cursor only if the current buffer is a browser.
  call s:move_cursor_to_entry_if_possible(a:path)
endfunction

function! s:browser_up_command() abort
  let l:path = expand('%:p')
  Explore
  call s:move_cursor_to_entry_if_possible(l:path)
endfunction

function! s:move_cursor_to_entry_if_possible(path) abort
  let l:absolute_path = resolve(a:path)
  let l:browser_path = resolve(expand('%:p'))
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
