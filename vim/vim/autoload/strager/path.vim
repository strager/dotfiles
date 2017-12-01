function! strager#path#join(paths)
  let [l:path; l:extra_paths] = a:paths
  for l:extra_path in l:extra_paths
    let l:path = s:join2(l:path, l:extra_path)
  endfor
  return l:path
endfunction

function! s:is_absolute(path)
  " HACK(strager): This is good enough for now...
  return a:path =~# '^/'
endfunction

function! s:join2(left, right)
  if a:left ==# ''
    return a:right
  endif
  if a:right ==# ''
    return a:left
  endif

  if s:is_absolute(a:right)
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
