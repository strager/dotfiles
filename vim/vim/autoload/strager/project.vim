function! strager#project#find_c_project(options)
  let l:buffer_path = strager#path#join([a:options['cwd'], a:options['buffer_path']])

  let l:found_files_infos = strager#file#find_file_upward_with_glob(
    \ l:buffer_path,
    \ '[Bb]uild*/compile_commands.json',
  \ )
  if !empty(l:found_files_infos)
    let l:found_files_info = l:found_files_infos[0]
    let l:compile_commands_path = l:found_files_info['parent_path'].'/'
      \ .l:found_files_info['file_paths'][0]
    return {
      \ 'build_path': fnamemodify(l:compile_commands_path, ':h'),
      \ 'compile_commands_path': l:compile_commands_path,
      \ 'source_path': l:found_files_info['parent_path'],
    \ }
  endif

  let l:found_files_infos = strager#file#find_file_upward_with_glob(
    \ l:buffer_path,
    \ 'compile_commands.json',
  \ )
  if !empty(l:found_files_infos)
    let l:found_files_info = l:found_files_infos[0]
    let l:compile_commands_path = l:found_files_info['parent_path'].'/'
      \ .l:found_files_info['file_paths'][0]
    return {
      \ 'build_path': l:found_files_info['parent_path'],
      \ 'compile_commands_path': l:compile_commands_path,
      \ 'source_path': l:found_files_info['parent_path'],
    \ }
  endif

  return {
    \ 'build_path': a:options['cwd'],
    \ 'compile_commands_path': v:none,
    \ 'source_path': a:options['cwd'],
  \ }
endfunction
