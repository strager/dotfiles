" See also these related works:
"
" * https://github.com/aehlke/vim-rename3 :Rename
" * https://github.com/danro/rename.vim :Rename
" * https://github.com/tpope/vim-eunuch :Move, :Rename
" * https://github.com/tpope/vim-fugitive :Gmove
" * https://www.vim.org/scripts/script.php?script_id=1928 :Rename
" * https://www.vim.org/scripts/script.php?script_id=2724 :Rename

function strager#move_file#move_current_buffer_file(new_path)
  if a:new_path ==# ''
    throw "E484: Can't open file <empty>"
  endif

  let l:buffer_number = bufnr('%')

  let l:new_buffer_number = strager#buffer#buffer_number_by_name(a:new_path)
  if l:new_buffer_number !=# -1 && l:new_buffer_number !=# l:buffer_number
    throw 'E139: File is loaded in another buffer'
  endif

  if getbufvar(l:buffer_number, '&buftype') ==# 'terminal'
    throw 'E32: No file name'
  endif

  let l:old_path = bufname(l:buffer_number)
  if l:old_path ==# ''
    throw 'E32: No file name'
  endif

  if getftype(l:old_path) ==# 'dir'
    throw 'E502: Cannot move a directory'
  endif

  if strager#file#are_files_same_by_path(l:old_path, a:new_path)
    return
  endif

  let l:new_file_type = getftype(a:new_path)
  if l:new_file_type !=# ''
    if l:new_file_type ==# 'dir'
      throw 'E17: File is a directory'
    endif
    throw 'E13: File exists'
  endif

  if strager#buffer#is_current_buffer_new()
    exec 'file '.fnameescape(a:new_path)
    return
  endif

  let l:old_permissions = getfperm(l:old_path)
  if l:old_permissions ==# ''
    throw "E484: Can't open file"
  endif
  silent earlier 1f
  try
    silent exec 'saveas '.fnameescape(a:new_path)
    bwipeout #
  finally
    silent later 1f
  endtry
  file
  " TODO(strager): Check for errors.
  call setfperm(a:new_path, l:old_permissions)
  " TODO(strager): Check for errors.
  call delete(l:old_path)
endfunction

function strager#move_file#register_command(options)
  let l:bang = ''
  if a:options['force']
    let l:bang = '!'
  endif
  exec printf(
    \ 'command%s -complete=file -nargs=1 Move %s',
    \ l:bang,
    \ 'call strager#move_file#move_current_buffer_file(<q-args>)',
  \ )
endfunction
