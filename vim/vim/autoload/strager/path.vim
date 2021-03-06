if has('unix')
  function! strager#path#components(path) abort
    return strager#path#components_posix(a:path)
  endfunction

  function! strager#path#join(paths) abort
    return strager#path#join_posix(a:paths)
  endfunction

  function! strager#path#make_relative(ancestor_path, descendant_path) abort
    return strager#path#make_relative_posix(a:ancestor_path, a:descendant_path)
  endfunction

  function! s:is_absolute(path) abort
    return s:is_absolute_posix(a:path)
  endfunction
elseif has('win32')
  function! strager#path#components(path) abort
    return strager#path#components_windows(a:path)
  endfunction

  function! strager#path#join(paths) abort
    return strager#path#join_windows(a:paths)
  endfunction

  function! strager#path#make_relative(ancestor_path, descendant_path) abort
    return strager#path#make_relative_windows(a:ancestor_path, a:descendant_path)
  endfunction

  function! s:is_absolute(path) abort
    return s:is_absolute_windows(a:path)
  endfunction
endif

function! strager#path#join_posix(paths) abort
  let [l:path; l:extra_paths] = a:paths
  for l:extra_path in l:extra_paths
    let l:path = s:join2_posix(l:path, l:extra_path)
  endfor
  return l:path
endfunction

function! strager#path#join_windows(paths) abort
  let [l:path; l:extra_paths] = a:paths
  for l:extra_path in l:extra_paths
    let l:path = s:join2_windows(l:path, l:extra_path)
  endfor
  return l:path
endfunction

function! strager#path#components_posix(path) abort
  let l:leading_slash_count = match(a:path, '[^/]')
  if l:leading_slash_count == -1
    let l:components = [a:path]
  else
    let l:components = split(a:path[l:leading_slash_count :], '/', v:true)
    if l:leading_slash_count > 0
      call insert(l:components, a:path[:l:leading_slash_count - 1], 0)
    endif
  endif
  return l:components
endfunction

function! strager#path#base_name(path) abort
  let l:tail = fnamemodify(a:path, ':t')
  if l:tail ==# ''
    return fnamemodify(a:path, ':h:t')
  endif
  return l:tail
endfunction

function! strager#path#components_windows(path) abort
  let l:leading_slash_count = match(a:path, '[^/\\]')
  if l:leading_slash_count == -1
    let l:components = [a:path]
  else
    let l:components = split(a:path[l:leading_slash_count :], '[/\\]', v:true)
    if l:leading_slash_count > 0
      call insert(l:components, a:path[:l:leading_slash_count - 1], 0)
    endif
  endif
  return l:components
endfunction

function! strager#path#paths_upward(path) abort
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
      if !s:is_absolute(l:path)
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

" TODO(strager): Deduplicate with strager#path#make_relative_windows.
function! strager#path#make_relative_posix(ancestor_path, descendant_path) abort
  let l:ancestor_components = strager#path#components_posix(a:ancestor_path)
  let l:descendant_components = strager#path#components_posix(a:descendant_path)
  if l:ancestor_components[-1] ==# ''
    " Ignore trailing / in ancestor path.
    call remove(l:ancestor_components, -1)
  endif

  let l:prefix_length = len(l:ancestor_components)
  if l:ancestor_components !=# l:descendant_components[:l:prefix_length - 1]
    throw printf(
      \ 'ES004: Path (%s) is not a descendant of %s',
      \ a:descendant_path,
      \ a:ancestor_path,
    \ )
  endif

  let l:relative_path_components = l:descendant_components[l:prefix_length :]
  if l:relative_path_components ==# [] || l:relative_path_components ==# ['']
    return '.'
  endif
  let l:relative_path = strager#path#join_posix(l:relative_path_components)
  if l:relative_path_components[-1] ==# ''
    let l:relative_path .= '/'
  endif
  return l:relative_path
endfunction

" TODO(strager): Deduplicate with strager#path#make_relative_posix.
function! strager#path#make_relative_windows(ancestor_path, descendant_path) abort
  let l:ancestor_components = strager#path#components_windows(a:ancestor_path)
  let l:descendant_components = strager#path#components_windows(a:descendant_path)
  if l:ancestor_components[-1] ==# ''
    " Ignore trailing / in ancestor path.
    call remove(l:ancestor_components, -1)
  endif

  let l:prefix_length = len(l:ancestor_components)
  if l:ancestor_components !=# l:descendant_components[:l:prefix_length - 1]
    throw printf(
      \ 'ES004: Path (%s) is not a descendant of %s',
      \ a:descendant_path,
      \ a:ancestor_path,
    \ )
  endif

  let l:relative_path_components = l:descendant_components[l:prefix_length :]
  if l:relative_path_components ==# [] || l:relative_path_components ==# ['']
    return '.'
  endif
  let l:relative_path = strager#path#join_windows(l:relative_path_components)
  if l:relative_path_components[-1] ==# ''
    let l:relative_path .= '\'
  endif
  return l:relative_path
endfunction

function! strager#path#is_relative(path) abort
  return !s:is_absolute(a:path)
endfunction

function! s:is_absolute_posix(path) abort
  " HACK(strager): This is good enough for now...
  return a:path =~# '^/'
endfunction

function! s:is_absolute_windows(path) abort
  return a:path =~# '^[/\\]\|^[A-Za-z]:[/\\]\?'
endfunction

function! s:join2_posix(left, right) abort
  if a:left ==# ''
    return a:right
  endif
  if a:right ==# ''
    return a:left
  endif

  if s:is_absolute_posix(a:right)
    return a:right
  endif

  let l:path = a:left
  if fnamemodify(l:path, ':t') !=# ''
    " Add a directory separator only if one doesn't already exist.
    let l:path = l:path.'/'
  endif
  let l:path = l:path.a:right
  return l:path
endfunction

function! s:join2_windows(left, right) abort
  if a:left ==# ''
    return a:right
  endif
  if a:right ==# ''
    return a:left
  endif

  if s:is_absolute_windows(a:right)
    return a:right
  endif

  let l:path = a:left
  if l:path !~# '[/\\]$'
    " Add a directory separator only if one doesn't already exist.
    let l:path = l:path.'\'
  endif
  let l:path = l:path.a:right
  return l:path
endfunction
