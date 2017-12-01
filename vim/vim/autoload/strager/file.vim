function! strager#file#make_directory_with_files(paths)
  let l:temp_path = tempname()
  let l:root_path = l:temp_path.'/__test_directory__'
  let l:directory_paths = [l:temp_path, l:root_path]
  let l:file_paths = []
  for l:path in a:paths
    if fnamemodify(l:path, ':t') ==# ''
      " l:path has no file name component.
      call add(l:directory_paths, l:root_path.'/'.l:path)
    else
      let l:path_dirs = fnamemodify(l:path, ':h')
      if l:path_dirs !=# '.'
        call add(l:directory_paths, l:root_path.'/'.l:path_dirs)
      endif
      call add(l:file_paths, l:root_path.'/'.l:path)
    endif
  endfor
  call uniq(l:directory_paths)
  for path in l:directory_paths
    call mkdir(l:path, 'p')
  endfor
  for path in l:file_paths
    new
    try
      exec 'write '.fnameescape(l:path)
    finally
      close!
    endtry
  endfor
  return l:root_path
endfunction

function! strager#file#file_exists_case_sensitive(path)
  let l:path = a:path
  " Strip trailing '/'.
  if fnamemodify(l:path, ':t') ==# ''
    let l:path = fnamemodify(l:path, ':h')
    if !isdirectory(l:path)
      return v:false
    endif
  endif
  for l:cur_path in strager#file#paths_upward(l:path)
    if !s:file_exists_single_case_sensitive(l:cur_path)
      return v:false
    endif
  endfor
  return v:true
endfunction

function! s:file_exists_single_case_sensitive(path)
  let l:name = fnamemodify(a:path, ':t')
  let l:dir = fnamemodify(a:path, ':h')
  if l:dir ==# a:path
    " a:path is '/' or '.'. Assume the file exists.
    return v:true
  endif
  try
    let l:names_in_dir = strager#file#list_directory(l:dir)
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

function! strager#file#paths_upward(path)
  let l:paths = []
  let l:path = a:path
  while v:true
    call add(l:paths, l:path)
    if l:path ==# fnamemodify(l:path, ':t')
      " NOTE(strager): Vim's documentation states that fnamemodify('name', ':h')
      " returns an empty string, but it actually returns '.'.
      break
    endif
    let l:parent_path = fnamemodify(l:path, ':h')
    if l:parent_path ==# l:path
      if l:path !=# '/'
        " FIXME(strager): Are there other cases where :h is a no-op?
        throw 'Failed to get parent of path: '.l:path
      endif
      break
    endif
    if strlen(l:parent_path) >= strlen(l:path)
      throw 'Failed to get parent of path: '.l:path
    endif
    let l:path = l:parent_path
  endwhile
  return l:paths
endfunction

function! strager#file#list_directory(path)
  silent let l:names = systemlist('/bin/ls -Hafv -- '.shellescape(a:path))
  if v:shell_error != 0
    throw 'Failed to list files in directory: '.a:path
  endif
  if count(l:names, '.') != 1
    throw 'Failed to list files in directory: '.a:path
  endif
  return l:names
endfunction

function! strager#file#find_file_upward_with_glob(path, glob)
  let l:matches = []
  for l:cur_path in strager#file#paths_upward(a:path)
    " FIXME(strager): How can we escape l:cur_path for glob()?
    let l:cur_path_glob_prefix = l:cur_path.'/'
    let l:cur_glob = l:cur_path_glob_prefix.a:glob
    let l:cur_matches = glob(l:cur_glob, v:true, v:true, v:true)
    if !empty(l:cur_matches)
      let l:file_paths = []
      for l:cur_match in l:cur_matches
        if strpart(l:cur_match, 0, len(l:cur_path_glob_prefix))
          \ !=# l:cur_path_glob_prefix
          " FIXME(strager): We should use a proper function to make the path
          " relative instead of string juggling.
          throw 'Unexpected result from glob('.string(l:cur_glob).'): '
            \ .string(l:cur_match)
        endif
        if strager#file#file_exists_case_sensitive(l:cur_match)
          call add(
            \ l:file_paths,
            \ strpart(l:cur_match, len(l:cur_path_glob_prefix)),
          \ )
        endif
      endfor
      if !empty(l:file_paths)
        call add(l:matches, {
          \ 'file_paths': l:file_paths,
          \ 'parent_path': l:cur_path,
        \ })
      endif
    endif
  endfor
  return l:matches
endfunction
