function! strager#search_files#search_using_fzf() abort
  let l:fzf_run_options =
    \ strager#search_files#get_fzf_run_options_for_searching_files()
  let l:fzf_run_options = fzf#wrap(l:fzf_run_options)
  call fzf#run(l:fzf_run_options)
endfunction

function! strager#search_files#get_fzf_run_options_for_searching_files() abort
  let l:prompt = pathshorten(fnamemodify(getcwd(), ':~'))
  if l:prompt !~# '/$'
    let l:prompt = l:prompt.'/'
  endif
  return {
    \ 'options': ['--delimiter= ', '--prompt='.l:prompt],
    \ 'sink*': {lines -> s:fzf_sink(lines)},
  \ }
endfunction

function! s:fzf_sink(lines) abort
  if len(a:lines) > 1
    throw 'ES013: Expected exactly zero or one lines'
  endif
  if a:lines ==# []
    return
  endif
  let [l:line] = a:lines
  execute printf('edit %s', fnameescape(l:line))
endfunction
