" See also these related works:
"
" * https://github.com/aehlke/vim-rename3 :Rename
" * https://github.com/danro/rename.vim :Rename
" * https://github.com/tpope/vim-eunuch :Move, :Rename
" * https://github.com/tpope/vim-fugitive :Gmove
" * https://www.vim.org/scripts/script.php?script_id=1928 :Rename
" * https://www.vim.org/scripts/script.php?script_id=2724 :Rename

function! strager#move_file#move_current_buffer_file(new_path) abort
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
  try
    call s:save_current_buffer_saved_changes_as(a:new_path)
  catch /E212:/
    call s:throw_cannot_open_file_for_writing_error(a:new_path)
  endtry
  file
  " TODO(strager): Check for errors.
  call setfperm(a:new_path, l:old_permissions)
  " TODO(strager): Check for errors.
  call delete(l:old_path)
endfunction

function! s:save_current_buffer_saved_changes_as(new_path) abort
  let l:had_unsaved_changes = s:current_buffer_has_unsaved_changes()
  if l:had_unsaved_changes
    silent earlier 1f
  endif
  try
    " HACK(strager): :saveas is basically :file followed by :write. If :saveas'
    " :write fails, the :file is not rolled back. Do :write followed by :file
    " manually to work around the limitations of :saveas.
    "
    " HACK(strager): :file sets the not-edited flag, preventing a following
    " :write from succeeding. The only way to remove this flag is to use
    " :write!. Unfortunately, the :write! is redundant with the :write! we just
    " did
    silent exec 'write '.fnameescape(a:new_path)
    silent exec 'file '.fnameescape(a:new_path)
    silent write!
    bwipeout #
  finally
    if l:had_unsaved_changes
      silent later 1f
    endif
  endtry
endfunction

function! s:throw_cannot_open_file_for_writing_error(path) abort
  for l:path in strager#path#paths_upward(a:path)
    if l:path != a:path
      let l:type = getftype(l:path)
      if l:type == ''
        throw 'ES001: Directory does not exist ('.l:path.')'
      endif
    endif
  endfor
  throw strager#exception#get_vim_error()
endfunction

function! s:current_buffer_has_unsaved_changes() abort
  " FIXME(strager): Reading 'modified is unreliable. Use undotree() instead.
  return getbufvar('%', '&modified')
endfunction

function! strager#move_file#register_command(options) abort
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
