function! strager#script#number_of_loaded_script(script_path)
  let l:script_path = fnamemodify(a:script_path, ':p')
  let l:scripts = s:loaded_scripts()
  for l:script in l:scripts
    if fnamemodify(l:script.path, ':p') ==# a:script_path
      return l:script.number
    endif
  endfor
  throw printf('ES005: Script not loaded: %s', a:script_path)
endfunction

function! s:loaded_scripts()
  let l:scripts = []
  let l:lines = split(execute('scriptnames'), "\n")
  for l:line in l:lines
    let [l:_, l:number, l:path; l:_] = matchlist(
      \ l:line,
      \ '\s*\(\d\+\): \(.*\)',
    \ )
    call add(l:scripts, {'number': str2nr(l:number), 'path': l:path})
  endfor
  return l:scripts
endfunction
