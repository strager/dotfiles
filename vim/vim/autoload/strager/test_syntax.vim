function! Test_syntax_loaded_by_edit_uses_fast_regexp_engine()
  let l:expected_regexpengine = 1
  let g:strager_test_syntax_regexpengine = v:none

  let l:test_runtime_path = strager#file#make_directory_with_files([[
    \ 'syntax/javascript.vim',
    \ 'let g:strager_test_syntax_regexpengine = &regexpengine',
  \ ]])

  let l:project_path = strager#file#make_directory_with_files([[
    \ 'test_file.js',
    \ 'cquit!',
  \ ]])
  let l:test_file_path = strager#path#join([l:project_path, 'test_file.js'])

  let l:old_runtimepath = &runtimepath
  try
    let &runtimepath = l:test_runtime_path.','.&runtimepath

    execute printf('edit %s', fnameescape(l:test_file_path))
  finally
    let &runtimepath = l:old_runtimepath
  endtry

  call assert_equal(
    \ l:expected_regexpengine,
    \ g:strager_test_syntax_regexpengine,
    \ 'regexpengine should be set while executing syntax files',
  \ )
endfunction

call strager#test#run_all_tests()
