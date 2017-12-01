function! Test_find_c_project()
  let l:root_path = strager#file#make_directory_with_files([])
  call assert_equal({
    \ 'build_path': l:root_path,
    \ 'compile_commands_path': v:none,
    \ 'source_path': l:root_path,
  \ }, strager#project#find_c_project({
    \ 'buffer_path': l:root_path,
    \ 'cwd': l:root_path,
  \ }))
  call assert_equal({
    \ 'build_path': l:root_path,
    \ 'compile_commands_path': v:none,
    \ 'source_path': l:root_path,
  \ }, strager#project#find_c_project({
    \ 'buffer_path': '.',
    \ 'cwd': l:root_path,
  \ }))
  call assert_equal({
    \ 'build_path': l:root_path,
    \ 'compile_commands_path': v:none,
    \ 'source_path': l:root_path,
  \ }, strager#project#find_c_project({
    \ 'buffer_path': l:root_path.'/new_file.c',
    \ 'cwd': l:root_path,
  \ }))
  call assert_equal({
    \ 'build_path': l:root_path,
    \ 'compile_commands_path': v:none,
    \ 'source_path': l:root_path,
  \ }, strager#project#find_c_project({
    \ 'buffer_path': 'new_file.c',
    \ 'cwd': l:root_path,
  \ }))

  let l:root_path = strager#file#make_directory_with_files([
    \ 'Makefile',
    \ 'bar/baz.c',
    \ 'compile_commands.json',
    \ 'foo.c',
  \ ])
  for l:buffer_path in [
    \ 'bar/baz.c',
    \ 'foo.c',
    \ l:root_path,
    \ l:root_path.'/bar/baz.c',
    \ l:root_path.'/foo.c',
  \ ]
    for l:cwd in [l:root_path, l:root_path.'/bar']
      call assert_equal({
        \ 'build_path': l:root_path,
        \ 'compile_commands_path': l:root_path.'/compile_commands.json',
        \ 'source_path': l:root_path,
      \ }, strager#project#find_c_project({
        \ 'buffer_path': l:buffer_path,
        \ 'cwd': l:cwd,
      \ }))
    endfor
  endfor

  let l:root_path = strager#file#make_directory_with_files([
    \ 'compile_commands.json',
    \ 'main.c',
    \ 'subproject/compile_commands.json',
    \ 'subproject/main.c',
  \ ])
  for [l:buffer_path, l:cwd] in [
    \ [l:root_path, l:root_path],
    \ [l:root_path, l:root_path.'/subproject'],
    \ [l:root_path.'/main.c', l:root_path],
    \ [l:root_path.'/main.c', l:root_path.'/subproject'],
    \ ['main.c', l:root_path],
  \ ]
    call assert_equal({
      \ 'build_path': l:root_path,
      \ 'compile_commands_path': l:root_path.'/compile_commands.json',
      \ 'source_path': l:root_path,
    \ }, strager#project#find_c_project({
      \ 'buffer_path': l:buffer_path,
      \ 'cwd': l:cwd,
    \ }))
  endfor
  for [l:buffer_path, l:cwd] in [
    \ ['main.c', l:root_path.'/subproject'],
    \ ['subproject', l:root_path.'/subproject'],
    \ ['subproject', l:root_path],
    \ ['subproject/main.c', l:root_path.'/subproject'],
    \ ['subproject/main.c', l:root_path],
    \ [l:root_path.'/subproject', l:root_path.'/subproject'],
    \ [l:root_path.'/subproject', l:root_path],
    \ [l:root_path.'/subproject/main.c', l:root_path.'/subproject'],
    \ [l:root_path.'/subproject/main.c', l:root_path],
  \ ]
    call assert_equal({
      \ 'build_path': l:root_path.'/subproject',
      \ 'compile_commands_path': l:root_path
        \ .'/subproject/compile_commands.json',
      \ 'source_path': l:root_path.'/subproject',
    \ }, strager#project#find_c_project({
      \ 'buffer_path': l:buffer_path,
      \ 'cwd': l:cwd,
    \ }))
  endfor

  let l:root_path = strager#file#make_directory_with_files([
    \ 'Makefile',
    \ 'bar/baz.c',
    \ 'build/compile_commands.json',
    \ 'build/foo.S',
    \ 'foo.c',
  \ ])
  for l:buffer_path in [
    \ 'bar/baz.c',
    \ 'build/foo.S',
    \ 'foo.c',
    \ l:root_path,
    \ l:root_path.'/bar/baz.c',
    \ l:root_path.'/build/foo.S',
    \ l:root_path.'/foo.c',
  \ ]
    for l:cwd in [l:root_path, l:root_path.'/bar']
      call assert_equal({
        \ 'build_path': l:root_path.'/build',
        \ 'compile_commands_path': l:root_path.'/build/compile_commands.json',
        \ 'source_path': l:root_path,
      \ }, strager#project#find_c_project({
        \ 'buffer_path': l:buffer_path,
        \ 'cwd': l:cwd,
      \ }))
    endfor
  endfor

  for l:build_dir_name in ['build', 'Build', 'Build-32']
    let l:root_path = strager#file#make_directory_with_files([
      \ l:build_dir_name.'/compile_commands.json',
      \ 'foo.c',
      \ 'bar/baz.c',
    \ ])
    for l:buffer_path in [
      \ 'bar/baz.c',
      \ 'foo.c',
      \ l:root_path,
      \ l:root_path.'/bar/baz.c',
      \ l:root_path.'/foo.c',
    \ ]
      for l:cwd in [l:root_path, l:root_path.'/bar']
        call assert_equal({
          \ 'build_path': l:root_path.'/'.l:build_dir_name,
          \ 'compile_commands_path': l:root_path.'/'.l:build_dir_name
            \ .'/compile_commands.json',
          \ 'source_path': l:root_path,
        \ }, strager#project#find_c_project({
          \ 'buffer_path': l:buffer_path,
          \ 'cwd': l:cwd,
        \ }))
      endfor
    endfor
  endfor
endfunction

call strager#test#run_all_tests()
