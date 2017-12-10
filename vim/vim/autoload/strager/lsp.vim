function strager#lsp#register_clangd_server()
  let l:project_info = strager#project#find_c_project({
    \ 'buffer_path': expand('%'),
    \ 'cwd': getcwd(),
  \ })

  let l:command = ['clangd']
  let l:compile_commands_path = l:project_info['compile_commands_path']
  if l:compile_commands_path !=# v:none
    call add(
      \ l:command,
      \ '-compile-commands-dir='.fnamemodify(l:compile_commands_path, ':h'),
    \ )
  endif

  " FIXME(strager): How can we register the server only for the current buffer?
  " vim-lsp's interface is so confusing.
  call lsp#register_server({
    \ 'cmd': {_ -> l:command},
    \ 'name': 'strager#lsp# clangd '.l:project_info['source_path'],
    \ 'root_uri': {_ -> lsp#utils#path_to_uri(l:project_info['source_path'])},
    \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp'],
  \ })
endfunction
