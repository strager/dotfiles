function! Test_test_dir_files_are_empty() abort
  let l:dir = strager#file#make_directory_with_files(['file.txt'])
  let l:file_lines = readfile(strager#path#join([l:dir, 'file.txt']), 'b')
  call assert_equal([''], l:file_lines)
endfunction

function! Test_test_dir_files_are_not_opened() abort
  let l:all_buffers_before = getbufinfo()
  let l:dir = strager#file#make_directory_with_files(['file.txt', 'dir/'])
  let l:all_buffers_after = getbufinfo()
  call assert_equal(l:all_buffers_before, l:all_buffers_after)
endfunction

function! Test_test_dir_files_have_content() abort
  let l:dir = strager#file#make_directory_with_files([
    \ ['file1.txt', "hello world\n"],
    \ ['file2.txt', "  x\ny  \r\nz"],
    \ 'file3.txt',
  \ ])

  let l:file1_lines = readfile(strager#path#join([l:dir, 'file1.txt']), 'b')
  call assert_equal(['hello world', ''], l:file1_lines)

  let l:file2_lines = readfile(strager#path#join([l:dir, 'file2.txt']), 'b')
  call assert_equal(['  x', "y  \r", 'z'], l:file2_lines)

  let l:file3_lines = readfile(strager#path#join([l:dir, 'file3.txt']), 'b')
  call assert_equal([''], l:file3_lines)
endfunction

function! Test_file_exists_case_sensitive() abort
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

function! Test_find_file_upward_with_glob() abort
  let l:Find = {path, glob ->
    \ strager#file#find_file_upward_with_glob(path, glob)}
  if has('win32')
    let l:sep = '\'
  else
    let l:sep = '/'
  endif

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
    \ 'file_paths': ['src'.l:sep.'main.c'],
    \ 'parent_path': l:root_path,
  \ }], l:Find(l:root_path, 'src'.l:sep.'main.c'))
  call assert_equal([{
    \ 'file_paths': ['src'],
    \ 'parent_path': l:root_path,
  \ }], l:Find(l:root_path, 'src'))
  call assert_equal([{
    \ 'file_paths': ['src'.l:sep],
    \ 'parent_path': l:root_path,
  \ }], l:Find(l:root_path, 'src'.l:sep))
  call assert_equal([{
    \ 'file_paths': ['src'.l:sep.'test'],
    \ 'parent_path': l:root_path,
  \ }], l:Find(l:root_path, 'src'.l:sep.'test'))
  call assert_equal([{
    \ 'file_paths': ['src'.l:sep.'test'.l:sep],
    \ 'parent_path': l:root_path,
  \ }], l:Find(l:root_path, 'src'.l:sep.'test'.l:sep))

  " Test globs.
  call assert_equal([{
    \ 'file_paths': ['Makefile'],
    \ 'parent_path': l:root_path,
  \ }], l:Find(l:root_path, 'Make*'))
  call assert_equal([{
    \ 'file_paths': ['src'.l:sep.'main.c'],
    \ 'parent_path': l:root_path,
  \ }], l:Find(l:root_path, 'src'.l:sep.'*.c'))
  call assert_equal([{
    \ 'file_paths': ['src'.l:sep.'test'.l:sep.'test0.c', 'src'.l:sep.'test'.l:sep.'test1.c'],
    \ 'parent_path': l:root_path,
  \ }], l:Find(l:root_path, 'src'.l:sep.'test'.l:sep.'*.c'))
  call assert_equal([{
    \ 'file_paths': ['src'.l:sep.'main.c', 'src'.l:sep.'test'.l:sep.'test0.c', 'src'.l:sep.'test'.l:sep.'test1.c'],
    \ 'parent_path': l:root_path,
  \ }], l:Find(l:root_path, 'src'.l:sep.'**'.l:sep.'*.c'))

  " Test upward searches with exact file names.
  call assert_equal([{
    \ 'file_paths': ['README.txt'],
    \ 'parent_path': l:root_path,
  \ }], l:Find(l:root_path.l:sep.'src', 'README.txt'))
  call assert_equal([{
    \ 'file_paths': ['README.txt'],
    \ 'parent_path': l:root_path,
  \ }], l:Find(l:root_path.l:sep.'src'.l:sep.'test', 'README.txt'))
  call assert_equal([{
    \ 'file_paths': ['main.c'],
    \ 'parent_path': l:root_path.l:sep.'src',
  \ }], l:Find(l:root_path.l:sep.'src'.l:sep.'test', 'main.c'))
  call assert_equal([{
    \ 'file_paths': ['src'.l:sep.'main.c'],
    \ 'parent_path': l:root_path,
  \ }], l:Find(l:root_path.l:sep.'src', 'src'.l:sep.'main.c'))
  call assert_equal([{
    \ 'file_paths': ['src'.l:sep.'main.c'],
    \ 'parent_path': l:root_path,
  \ }], l:Find(l:root_path.l:sep.'src'.l:sep.'test', 'src'.l:sep.'main.c'))
  call assert_equal([{
    \ 'file_paths': ['Makefile'],
    \ 'parent_path': l:root_path.l:sep.'src',
  \ }, {
    \ 'file_paths': ['Makefile'],
    \ 'parent_path': l:root_path,
  \ }], l:Find(l:root_path.l:sep.'src', 'Makefile'))
  call assert_equal([{
    \ 'file_paths': ['Makefile'],
    \ 'parent_path': l:root_path.l:sep.'src'.l:sep.'test',
  \ }, {
    \ 'file_paths': ['Makefile'],
    \ 'parent_path': l:root_path.l:sep.'src',
  \ }, {
    \ 'file_paths': ['Makefile'],
    \ 'parent_path': l:root_path,
  \ }], l:Find(l:root_path.l:sep.'src'.l:sep.'test', 'Makefile'))
endfunction

function! Test_list_empty_directory() abort
  let l:path = strager#file#make_directory_with_files([])
  call assert_equal(['.', '..'], s:list(l:path))
endfunction

function! Test_listing_directory_includes_regular_files() abort
  let l:path = strager#file#make_directory_with_files(['file'])
  call assert_equal(['.', '..', 'file'], s:list(l:path))
endfunction

function! Test_listing_directory_includes_subdirectories() abort
  let l:path = strager#file#make_directory_with_files(['dir/'])
  call assert_equal(['.', '..', 'dir'], s:list(l:path))
endfunction

if !has('win32')
  function! Test_listing_directory_includes_symlinks_to_directories() abort
    let l:path = strager#file#make_directory_with_files(['dir'])
    call strager#file#create_symbolic_link('dir', strager#path#join([l:path, 'symlink_to_dir']))
    call assert_equal(['.', '..', 'dir', 'symlink_to_dir'], s:list(l:path))
  endfunction

  function! Test_listing_directory_includes_symlinks_to_regular_files() abort
    let l:path = strager#file#make_directory_with_files(['file'])
    call strager#file#create_symbolic_link('file', strager#path#join([l:path, 'symlink_to_file']))
    call assert_equal(['.', '..', 'file', 'symlink_to_file'], s:list(l:path))
  endfunction

  function! Test_listing_directory_includes_symlinks_to_non_existing_paths() abort
    let l:path = strager#file#make_directory_with_files([])
    call strager#file#create_symbolic_link('does_not_exist', strager#path#join([l:path, 'broken_symlink']))
    call assert_equal(['.', '..', 'broken_symlink'], s:list(l:path))
  endfunction
endif

function! Test_listing_directory_includes_dot_files() abort
  let l:path = strager#file#make_directory_with_files(['.vimrc', '.vim/'])
  call assert_equal(['.', '..', '.vim', '.vimrc'], s:list(l:path))
endfunction

function! Test_listing_directory_with_name_containing_special_characters_lists_files() abort
  " Check special characters: comma, space, \.
  let l:path = strager#file#make_directory_with_files(['stuff, things, and junk/closet.jpeg'])
  call assert_equal(['.', '..', 'closet.jpeg'], s:list(l:path.'/stuff, things, and junk'))
  if !has('win32')
    let l:path = strager#file#make_directory_with_files(['trailing-slash\/file.txt'])
    call assert_equal(['.', '..', 'file.txt'], s:list(l:path.'/trailing-slash\'))
  endif
endfunction

function! Test_listing_non_existing_path_fails() abort
  let l:path = strager#file#make_directory_with_files([])
  call strager#assert#assert_throws(
    \ {-> s:list(l:path.'/dir-does-not-exist')},
    \ 'ES001:',
  \ )
endfunction

function! Test_list_regular_file_as_directory_fails() abort
  let l:path = strager#file#make_directory_with_files(['file.zip'])
  call strager#assert#assert_throws(
    \ {-> s:list(l:path.'/file.zip')},
    \ 'ES015:',
  \ )
endfunction

function! Test_listing_filesystem_root_includes_dot_and_dotdot() abort
  let l:names = strager#file#list_directory('/')
  if has('unix')
    call assert_notequal(-1, index(l:names, '.'))
    call assert_notequal(-1, index(l:names, '..'))
  endif
endfunction

function! Test_listing_filesystem_root_includes_existing_files() abort
  let l:names = strager#file#list_directory('/')
  for l:name in l:names
    " TODO(strager): Escape wildcards.
    let l:path = '/'.l:name
    call assert_notequal(getftype(l:path), '', printf('%s should exist', l:path))
  endfor
endfunction

function! s:list(path) abort
  return sort(strager#file#list_directory(a:path))
endfunction

function! Test_regular_files_are_same_with_same_absolute_path() abort
  let l:dir_path = strager#file#make_directory_with_files(['file.txt'])
  let l:file_path = strager#path#join([l:dir_path, 'file.txt'])
  call assert_true(s:are_files_same_by_path(l:file_path, l:file_path))
endfunction

function! Test_regular_files_are_same_with_relative_path() abort
  let l:dir_path = strager#file#make_directory_with_files(['file.txt'])
  exec 'cd '.fnameescape(l:dir_path)
  call assert_true(s:are_files_same_by_path('file.txt', 'file.txt'))
  call assert_true(s:are_files_same_by_path('file.txt', './file.txt'))
  call assert_true(s:are_files_same_by_path('./file.txt', 'file.txt'))
  call assert_true(s:are_files_same_by_path('./file.txt', './file.txt'))
endfunction

function! Test_regular_files_are_same_with_mixed_absolute_relative_path() abort
  let l:dir_path = strager#file#make_directory_with_files(['file.txt'])
  let l:file_path = strager#path#join([l:dir_path, 'file.txt'])
  exec 'cd '.fnameescape(l:dir_path)
  call assert_true(s:are_files_same_by_path('file.txt', l:file_path))
  call assert_true(s:are_files_same_by_path(l:file_path, 'file.txt'))
endfunction

if !has('win32')
  function! Test_regular_files_in_directory_symlinks_are_same() abort
    let l:dir_path = strager#file#make_directory_with_files(['dir_a/file.txt'])
    let l:dir_a_file_path = strager#path#join([l:dir_path, 'dir_a', 'file.txt'])
    let l:dir_b_path = strager#path#join([l:dir_path, 'dir_b'])
    let l:dir_b_file_path = strager#path#join([l:dir_path, 'dir_b', 'file.txt'])
    call strager#file#create_symbolic_link('dir_a', l:dir_b_path)
    call assert_true(s:are_files_same_by_path(
      \ l:dir_a_file_path,
      \ l:dir_b_file_path,
    \ ))
    call assert_true(s:are_files_same_by_path(
      \ l:dir_b_file_path,
      \ l:dir_a_file_path,
    \ ))
  endfunction
endif

function! Test_regular_files_are_different() abort
  let l:dir_path = strager#file#make_directory_with_files(['a.txt', 'b.txt'])
  let l:a_path = strager#path#join([l:dir_path, 'a.txt'])
  let l:b_path = strager#path#join([l:dir_path, 'b.txt'])
  call assert_false(s:are_files_same_by_path(l:a_path, l:b_path))
  call assert_false(s:are_files_same_by_path(l:b_path, l:a_path))
endfunction

function! Test_directories_are_same_with_same_absolute_path() abort
  let l:dir_path = strager#file#make_directory_with_files([])
  call assert_true(s:are_files_same_by_path(l:dir_path, l:dir_path))
endfunction

function! Test_directories_are_same_with_absolute_path_and_trailing_slashes() abort
  let l:dir_path = strager#file#make_directory_with_files([])
  call assert_true(s:are_files_same_by_path(l:dir_path, l:dir_path.'/'))
  call assert_true(s:are_files_same_by_path(l:dir_path.'/', l:dir_path))
  call assert_true(s:are_files_same_by_path(l:dir_path.'/', l:dir_path.'/'))
  call assert_true(s:are_files_same_by_path(l:dir_path, l:dir_path.'////'))
endfunction

function! Test_files_are_not_same_if_either_path_is_missing() abort
  let l:dir_path = strager#file#make_directory_with_files(['file.txt'])
  let l:file_path = strager#path#join([l:dir_path, 'file.txt'])
  call assert_false(s:are_files_same_by_path(l:file_path, l:file_path.'xxx'))
  call assert_false(s:are_files_same_by_path(l:file_path.'xxx', l:file_path))
  call assert_false(s:are_files_same_by_path(
    \ l:file_path.'xxx',
    \ l:file_path.'xxx',
  \ ))
endfunction

if !has('win32')
  function! Test_broken_symlinks_are_same() abort
    let l:dir_path = strager#file#make_directory_with_files([])
    let l:symlink_path = strager#path#join([l:dir_path, 'symlink.txt'])
    call strager#file#create_symbolic_link('file.txt', l:symlink_path)
    call assert_true(s:are_files_same_by_path(l:symlink_path, l:symlink_path))
  endfunction

  function! Test_symlinks_are_same() abort
    let l:dir_path = strager#file#make_directory_with_files(['file.txt'])
    let l:symlink_path = strager#path#join([l:dir_path, 'symlink.txt'])
    call strager#file#create_symbolic_link('file.txt', l:symlink_path)
    call assert_true(s:are_files_same_by_path(l:symlink_path, l:symlink_path))
  endfunction

  function! Test_broken_symlink_and_target_are_different() abort
    let l:dir_path = strager#file#make_directory_with_files([])
    let l:target_path = strager#path#join([l:dir_path, 'target.txt'])
    let l:symlink_path = strager#path#join([l:dir_path, 'symlink.txt'])
    call strager#file#create_symbolic_link('target.txt', l:symlink_path)
    call assert_false(s:are_files_same_by_path(l:symlink_path, l:target_path))
    call assert_false(s:are_files_same_by_path(l:target_path, l:symlink_path))
  endfunction

  function! Test_symlink_and_relative_target_are_different() abort
    let l:dir_path = strager#file#make_directory_with_files(['target.txt'])
    let l:target_path = strager#path#join([l:dir_path, 'target.txt'])
    let l:symlink_path = strager#path#join([l:dir_path, 'symlink.txt'])
    call strager#file#create_symbolic_link('target.txt', l:symlink_path)
    call assert_false(s:are_files_same_by_path(l:symlink_path, l:target_path))
    call assert_false(s:are_files_same_by_path(l:target_path, l:symlink_path))
  endfunction

  function! Test_hard_links_are_different() abort
    let l:dir_path = strager#file#make_directory_with_files(['a.txt'])
    let l:a_path = strager#path#join([l:dir_path, 'a.txt'])
    let l:b_path = strager#path#join([l:dir_path, 'b.txt'])
    call strager#file#create_hard_link(l:a_path, l:b_path)
    call assert_false(s:are_files_same_by_path(l:a_path, l:b_path))
    call assert_false(s:are_files_same_by_path(l:b_path, l:a_path))
  endfunction
endif

function! Test_mkdirp_creates_single_empty_directory() abort
  let l:temp_dir_path = strager#file#make_directory_with_files([])
  let l:new_dir_path = strager#path#join([l:temp_dir_path, 'hello'])
  call s:mkdirp(l:new_dir_path)
  call assert_true(isdirectory(l:new_dir_path))
  call assert_equal(['.', '..'], strager#file#list_directory(l:new_dir_path))
endfunction

function! Test_mkdirp_creates_nested_directories() abort
  let l:temp_dir_path = strager#file#make_directory_with_files([])
  call s:mkdirp(strager#path#join([l:temp_dir_path, 'hello', 'world', 'leaf']))
  call assert_true(isdirectory(strager#path#join([l:temp_dir_path, 'hello'])))
  call assert_true(isdirectory(strager#path#join([l:temp_dir_path, 'hello', 'world'])))
  call assert_true(isdirectory(strager#path#join([l:temp_dir_path, 'hello', 'world', 'leaf'])))
endfunction

function! Test_mkdirp_succeeds_if_directory_exists() abort
  let l:temp_dir_path = strager#file#make_directory_with_files(['hello/'])
  let l:new_dir_path = strager#path#join([l:temp_dir_path, 'hello'])
  call assert_true(isdirectory(l:new_dir_path))
  call s:mkdirp(l:new_dir_path)
  call assert_true(isdirectory(l:new_dir_path))
endfunction

function! s:mkdirp(path) abort
  call strager#file#mkdirp(a:path)
endfunction

function! s:are_files_same_by_path(file_a_path, file_b_path) abort
  return strager#file#are_files_same_by_path(a:file_a_path, a:file_b_path)
endfunction

call strager#test#run_all_tests()
