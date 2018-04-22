function! strager#file#make_directory_with_files(entries)
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
    call mkdir(l:path, 'p')
  endfor
  for [l:path, l:content] in items(l:files)
    call s:write_string_to_file(l:path, l:content)
  endfor
  return l:root_path
endfunction

function s:decode_file_entry(entry)
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

function s:write_string_to_file(path, content)
  let l:lines = split(a:content, "\n", v:true)
  call writefile(l:lines, a:path, 'b')
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
  let l:glob = escape(a:path, ',\')
  if fnamemodify(a:path, ':t') ==# ''
    let l:prefix_to_strip = a:path
  else
    let l:prefix_to_strip = a:path.'/'
  endif
  let l:paths = globpath(l:glob, '*', v:true, v:true, v:true)
  let l:paths += globpath(l:glob, '.*', v:true, v:true, v:true)
  if empty(l:paths)
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

function strager#file#create_symbolic_link(target_path, symlink_path)
  silent call system(printf(
    \ 'ln -s -- %s %s',
    \ shellescape(a:target_path),
    \ shellescape(a:symlink_path),
  \ ))
  if v:shell_error != 0
    throw 'Failed to create '.a:symlink_path
  endif
endfunction

function strager#file#create_hard_link(old_path, new_path)
  silent call system(printf(
    \ 'ln -- %s %s',
    \ shellescape(a:old_path),
    \ shellescape(a:new_path),
  \ ))
  if v:shell_error != 0
    throw 'Failed to create '.a:new_path
  endif
endfunction

function strager#file#are_files_same_by_path(file_a_path, file_b_path)
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
  if l:file_a_full_path ==# l:file_b_full_path
    return v:true
  endif
  return v:false
endfunction

function s:absolute_path_with_parent_resolved(path)
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
