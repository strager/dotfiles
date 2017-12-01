function! Test_file_exists_case_sensitive()
  let l:Exists = {path -> strager#file#file_exists_case_sensitive(path)}

  call assert_true(l:Exists('/'))

  let l:dir = strager#file#make_directory_with_files([])
  call assert_false(l:Exists(l:dir.'/missing_dir/'))
  call assert_false(l:Exists(l:dir.'/missing_dir/missing_file'))
  call assert_false(l:Exists(l:dir.'/missing_file'))
  call assert_true(l:Exists(l:dir))
  call assert_true(l:Exists(l:dir.'/'))
  call assert_true(l:Exists(l:dir.'/.'))

  let l:dir = strager#file#make_directory_with_files(['file.c'])
  call assert_false(l:Exists(l:dir.'/FILE.C'))
  call assert_false(l:Exists(l:dir.'/File.c'))
  call assert_false(l:Exists(l:dir.'/file.c/'))
  call assert_false(l:Exists(l:dir.'/file.c/.'))
  call assert_false(l:Exists(l:dir.'/file.c/..'))
  call assert_true(l:Exists(l:dir.'/file.c'))

  let l:dir = strager#file#make_directory_with_files(['File.c'])
  call assert_false(l:Exists(l:dir.'/FILE.C'))
  call assert_false(l:Exists(l:dir.'/File.c/'))
  call assert_false(l:Exists(l:dir.'/File.c/.'))
  call assert_false(l:Exists(l:dir.'/File.c/..'))
  call assert_false(l:Exists(l:dir.'/file.c'))
  call assert_true(l:Exists(l:dir.'/File.c'))

  let l:dir = strager#file#make_directory_with_files(['dir/'])
  call assert_false(l:Exists(l:dir.'/Dir'))
  call assert_false(l:Exists(l:dir.'/Dir/'))
  call assert_false(l:Exists(l:dir.'/Dir/..'))
  call assert_false(l:Exists(l:dir.'/Dir/../dir'))
  call assert_true(l:Exists(l:dir.'/dir'))
  call assert_true(l:Exists(l:dir.'/dir/'))
  call assert_true(l:Exists(l:dir.'/dir/..'))
  call assert_true(l:Exists(l:dir.'/dir/../'))
  call assert_true(l:Exists(l:dir.'/dir/../dir'))

  let l:dir = strager#file#make_directory_with_files(['SubDirectory/file.c'])
  call assert_false(l:Exists(l:dir.'/SubDirectory/File.c'))
  call assert_false(l:Exists(l:dir.'/subdirectory'))
  call assert_false(l:Exists(l:dir.'/subdirectory/'))
  call assert_false(l:Exists(l:dir.'/subdirectory/file.c'))
  call assert_true(l:Exists(l:dir.'/SubDirectory'))
  call assert_true(l:Exists(l:dir.'/SubDirectory/'))
  call assert_true(l:Exists(l:dir.'/SubDirectory/file.c'))
endfunction

function! Test_paths_upward()
  call assert_equal(['/'], strager#file#paths_upward('/'))
  call assert_equal([
    \ '/path/to/file',
    \ '/path/to',
    \ '/path',
    \ '/',
  \ ], strager#file#paths_upward('/path/to/file'))
  call assert_equal([
    \ '/path/to/../from/dir',
    \ '/path/to/../from',
    \ '/path/to/..',
    \ '/path/to',
    \ '/path',
    \ '/',
  \ ], strager#file#paths_upward('/path/to/../from/dir'))
  call assert_equal([
    \ '/path/to/dir/',
    \ '/path/to/dir',
    \ '/path/to',
    \ '/path',
    \ '/',
  \ ], strager#file#paths_upward('/path/to/dir/'))
  call assert_equal([
    \ '/path/to/dir/.',
    \ '/path/to/dir',
    \ '/path/to',
    \ '/path',
    \ '/',
  \ ], strager#file#paths_upward('/path/to/dir/.'))

  call assert_equal(['path'], strager#file#paths_upward('path'))
  call assert_equal([
    \ 'path/to/file',
    \ 'path/to',
    \ 'path',
  \ ], strager#file#paths_upward('path/to/file'))
  call assert_equal([
    \ 'path/to/../from/dir',
    \ 'path/to/../from',
    \ 'path/to/..',
    \ 'path/to',
    \ 'path',
  \ ], strager#file#paths_upward('path/to/../from/dir'))
  call assert_equal([
    \ 'path/to/dir/',
    \ 'path/to/dir',
    \ 'path/to',
    \ 'path',
  \ ], strager#file#paths_upward('path/to/dir/'))
  call assert_equal([
    \ 'path/to/dir/.',
    \ 'path/to/dir',
    \ 'path/to',
    \ 'path',
  \ ], strager#file#paths_upward('path/to/dir/.'))

  call assert_equal(['.'], strager#file#paths_upward('.'))
  call assert_equal([
    \ './path/to/file',
    \ './path/to',
    \ './path',
    \ '.',
  \ ], strager#file#paths_upward('./path/to/file'))

  call assert_equal(['..'], strager#file#paths_upward('..'))
  call assert_equal([
    \ '../path/to/file',
    \ '../path/to',
    \ '../path',
    \ '..',
  \ ], strager#file#paths_upward('../path/to/file'))
endfunction

function! Test_find_file_upward_with_glob()
  let l:Find = {path, glob ->
    \ strager#file#find_file_upward_with_glob(path, glob)}

  let l:root_path = strager#file#make_directory_with_files([
    \ 'Makefile',
    \ 'README.txt',
    \ 'src/Makefile',
    \ 'src/main.c',
    \ 'src/test/Makefile',
    \ 'src/test/test0.c',
    \ 'src/test/test1.c',
  \ ])

  " Test missing files.
  call assert_equal([], l:Find(l:root_path, 'doesnotexist'))
  call assert_equal([], l:Find(l:root_path, 'makefile'))
  call assert_equal([], l:Find(l:root_path, 'readme.txt'))
  call assert_equal([], l:Find(l:root_path, 'src/doesnotexist'))

  " Test exact file names.
  call assert_equal([{
    \ 'file_paths': ['Makefile'],
    \ 'parent_path': l:root_path,
  \ }], l:Find(l:root_path, 'Makefile'))
  call assert_equal([{
    \ 'file_paths': ['README.txt'],
    \ 'parent_path': l:root_path,
  \ }], l:Find(l:root_path, 'README.txt'))
  call assert_equal([{
    \ 'file_paths': ['src/main.c'],
    \ 'parent_path': l:root_path,
  \ }], l:Find(l:root_path, 'src/main.c'))
  call assert_equal([{
    \ 'file_paths': ['src'],
    \ 'parent_path': l:root_path,
  \ }], l:Find(l:root_path, 'src'))
  call assert_equal([{
    \ 'file_paths': ['src/'],
    \ 'parent_path': l:root_path,
  \ }], l:Find(l:root_path, 'src/'))
  call assert_equal([{
    \ 'file_paths': ['src/test'],
    \ 'parent_path': l:root_path,
  \ }], l:Find(l:root_path, 'src/test'))
  call assert_equal([{
    \ 'file_paths': ['src/test/'],
    \ 'parent_path': l:root_path,
  \ }], l:Find(l:root_path, 'src/test/'))

  " Test globs.
  call assert_equal([{
    \ 'file_paths': ['Makefile'],
    \ 'parent_path': l:root_path,
  \ }], l:Find(l:root_path, 'Make*'))
  call assert_equal([{
    \ 'file_paths': ['src/main.c'],
    \ 'parent_path': l:root_path,
  \ }], l:Find(l:root_path, 'src/*.c'))
  call assert_equal([{
    \ 'file_paths': ['src/test/test0.c', 'src/test/test1.c'],
    \ 'parent_path': l:root_path,
  \ }], l:Find(l:root_path, 'src/test/*.c'))
  call assert_equal([{
    \ 'file_paths': ['src/main.c', 'src/test/test0.c', 'src/test/test1.c'],
    \ 'parent_path': l:root_path,
  \ }], l:Find(l:root_path, 'src/**/*.c'))

  " Test upward searches with exact file names.
  call assert_equal([{
    \ 'file_paths': ['README.txt'],
    \ 'parent_path': l:root_path,
  \ }], l:Find(l:root_path.'/src', 'README.txt'))
  call assert_equal([{
    \ 'file_paths': ['README.txt'],
    \ 'parent_path': l:root_path,
  \ }], l:Find(l:root_path.'/src/test', 'README.txt'))
  call assert_equal([{
    \ 'file_paths': ['main.c'],
    \ 'parent_path': l:root_path.'/src',
  \ }], l:Find(l:root_path.'/src/test', 'main.c'))
  call assert_equal([{
    \ 'file_paths': ['src/main.c'],
    \ 'parent_path': l:root_path,
  \ }], l:Find(l:root_path.'/src', 'src/main.c'))
  call assert_equal([{
    \ 'file_paths': ['src/main.c'],
    \ 'parent_path': l:root_path,
  \ }], l:Find(l:root_path.'/src/test', 'src/main.c'))
  call assert_equal([{
    \ 'file_paths': ['Makefile'],
    \ 'parent_path': l:root_path.'/src',
  \ }, {
    \ 'file_paths': ['Makefile'],
    \ 'parent_path': l:root_path,
  \ }], l:Find(l:root_path.'/src', 'Makefile'))
  call assert_equal([{
    \ 'file_paths': ['Makefile'],
    \ 'parent_path': l:root_path.'/src/test',
  \ }, {
    \ 'file_paths': ['Makefile'],
    \ 'parent_path': l:root_path.'/src',
  \ }, {
    \ 'file_paths': ['Makefile'],
    \ 'parent_path': l:root_path,
  \ }], l:Find(l:root_path.'/src/test', 'Makefile'))
endfunction

call strager#test#run_all_tests()
