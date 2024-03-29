function! strager#file#make_directory_with_files(entries) abort
  let l:temp_path = tempname()
  let l:root_path = l:temp_path.'/__test_directory__'
  let l:directory_paths = [l:temp_path, l:root_path]
  let l:files = {}
  for l:entry in a:entries
    let [l:path, l:file_content] = s:decode_file_entry(l:entry)
    if fnamemodify(l:path, ':t') ==# ''
      " l:path has no file name component.
      call add(l:directory_paths, l:root_path.'/'.l:path)
    else
      let l:path_dirs = fnamemodify(l:path, ':h')
      if l:path_dirs !=# '.'
        call add(l:directory_paths, l:root_path.'/'.l:path_dirs)
      endif
      let l:files[l:root_path.'/'.l:path] = l:file_content
    endif
  endfor
  call uniq(l:directory_paths)
  for path in l:directory_paths
    call strager#file#mkdirp(l:path)
  endfor
  for [l:path, l:content] in items(l:files)
    call s:write_string_to_file(l:path, l:content)
  endfor
  return l:root_path
endfunction

function! s:decode_file_entry(entry) abort
  let l:entry_type = type(a:entry)
  if l:entry_type ==# v:t_string
    return [a:entry, '']
  elseif l:entry_type ==# v:t_list
    let [l:path, l:file_content] = a:entry
    return [l:path, l:file_content]
  else
    throw 'Expected string or [string, string], but got: '.string(a:entry)
  endif
endfunction

function! s:write_string_to_file(path, content) abort
  let l:lines = split(a:content, "\n", v:true)
  call writefile(l:lines, a:path, 'b')
endfunction

function! strager#file#file_exists_case_sensitive(path) abort
  let l:path = a:path
  " Strip trailing '/'.
  if fnamemodify(l:path, ':t') ==# ''
    let l:path = fnamemodify(l:path, ':h')
    if !isdirectory(l:path)
      return v:false
    endif
  endif
  for l:cur_path in strager#path#paths_upward(l:path)
    if !s:file_exists_single_case_sensitive(l:cur_path)
      return v:false
    endif
  endfor
  return v:true
endfunction

function! s:file_exists_single_case_sensitive(path) abort
  let l:name = fnamemodify(a:path, ':t')
  let l:dir = fnamemodify(a:path, ':h')
  if l:dir ==# a:path
    " a:path is '/' or '.'. Assume the file exists.
    return v:true
  endif
  try
    let l:names_in_dir = strager#file#list_directory(l:dir)
  catch /^\%(ES001\|ES015\):/
    return v:false
  catch /^Failed to list files in directory:/
    return v:false
  endtry
  let l:matches = count(l:names_in_dir, l:name)
  if l:matches > 1
    throw 'Unexpectedly found '.shellescape(l:name).' twice in '
      \ .shellescape(l:dir)
  endif
  return l:matches == 1
endfunction

if has('win32')
  let s:runtimepath_characters_to_escape = ','
else
  let s:runtimepath_characters_to_escape = ',\'
endif

function! strager#file#list_directory(path) abort
  let l:glob = escape(a:path, s:runtimepath_characters_to_escape)
  if fnamemodify(a:path, ':t') ==# ''
    let l:prefix_to_strip = a:path
  else
    let l:prefix_to_strip = a:path.'/'
  endif
  let l:prefix_to_strip = s:normalize_path_as_glob_result(l:prefix_to_strip)
  let l:paths = globpath(l:glob, '*', v:true, v:true, v:true)
  let l:paths += globpath(l:glob, '.*', v:true, v:true, v:true)
  if empty(l:paths)
    let l:path_type = getftype(a:path)
    if l:path_type ==# ''
      throw printf('ES001: Directory does not exist: %s', a:path)
    endif
    if l:path_type ==# 'file'
      throw printf('ES015: Cannot list files in non-directory: %s', a:path)
    endif
    throw 'Failed to list files in directory: '.a:path
  endif
  let l:names = []
  for l:path in l:paths
    if l:path[0:len(l:prefix_to_strip) - 1] !=# l:prefix_to_strip
      " FIXME(strager): We should use a proper function to make the path
      " relative instead of string juggling.
      throw 'Unexpected result from glob('.string(l:glob).'): '.string(l:path)
    endif
    call add(l:names, l:path[len(l:prefix_to_strip):])
  endfor
  return l:names
endfunction

" HACK(strager): On Windows, globpath returns paths with \ as the component
" spearator, even if the input path uses /.
function! s:normalize_path_as_glob_result(path) abort
  if has('win32')
    return substitute(a:path, '/', '\', 'g')
  else
    return a:path
  endif
endfunction

function! strager#file#create_symbolic_link(target_path, symlink_path) abort
  if has('win32')
    throw 'Creating symbolic links is not yet implemented for Windows'
  endif
  silent call system(printf(
    \ 'ln -s -- %s %s',
    \ shellescape(a:target_path),
    \ shellescape(a:symlink_path),
  \ ))
  if v:shell_error != 0
    throw 'Failed to create '.a:symlink_path
  endif
endfunction

function! strager#file#create_hard_link(old_path, new_path) abort
  if has('win32')
    throw 'Creating hard links is not yet implemented for Windows'
  endif
  silent call system(printf(
    \ 'ln -- %s %s',
    \ shellescape(a:old_path),
    \ shellescape(a:new_path),
  \ ))
  if v:shell_error != 0
    throw 'Failed to create '.a:new_path
  endif
endfunction

function! strager#file#mkdirp(path) abort
  call mkdir(a:path, 'p')
endfunction

function! strager#file#are_files_same_by_path(file_a_path, file_b_path) abort
  let l:file_a_type = getftype(a:file_a_path)
  if l:file_a_type ==# ''
    return v:false
  endif
  let l:file_b_type = getftype(a:file_b_path)
  if l:file_b_type ==# ''
    return v:false
  endif

  let l:file_a_full_path = s:absolute_path_with_parent_resolved(a:file_a_path)
  let l:file_b_full_path = s:absolute_path_with_parent_resolved(a:file_b_path)
  if s:normalize_path_component_separators(l:file_a_full_path)
    \ ==# s:normalize_path_component_separators(l:file_b_full_path)
    return v:true
  endif
  return v:false
endfunction

function! s:absolute_path_with_parent_resolved(path) abort
  let l:absolute_path = strager#path#join([getcwd(), a:path])
  let l:parent_absolute_path = fnamemodify(a:path, ':p')
  let l:parent_resolved_absolute_path = resolve(l:parent_absolute_path)
  let l:name = fnamemodify(a:path, ':t')
  if l:name ==# ''
    " HACK(strager): Drop trailing slashes.
    let l:name = fnamemodify(a:path, ':h:t')
  endif
  return strager#path#join([l:parent_resolved_absolute_path, l:name])
endfunction

if has('win32')
  function! s:normalize_path_component_separators(path) abort
    return substitute(a:path, '/', '\', 'g')
  endfunction
else
  function! s:normalize_path_component_separators(path) abort
    return a:path
  endfunction
endif
