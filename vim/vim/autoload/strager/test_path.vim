" FIXME(strager): How should strager#path#join and strager#path#components
" relate?

function! Test_join_paths()
  " Join with an empty string.
  call assert_equal('', strager#path#join(['', '']))
  call assert_equal('.', strager#path#join(['.', '']))
  call assert_equal('/', strager#path#join(['', '/']))
  call assert_equal('/', strager#path#join(['/', '']))
  call assert_equal('a', strager#path#join(['', 'a']))
  call assert_equal('a', strager#path#join(['a', '']))
  call assert_equal('a/', strager#path#join(['', 'a/']))
  call assert_equal('a/', strager#path#join(['a/', '']))
  call assert_equal('a//', strager#path#join(['', 'a//']))
  call assert_equal('a//', strager#path#join(['a//', '']))

  " Join an absolute path with a relative path.
  call assert_equal('//a/b/c', strager#path#join(['//', 'a/b/c']))
  call assert_equal('/a//b/c', strager#path#join(['/a//', 'b/c']))
  call assert_equal('/a/b//c', strager#path#join(['/a/b//', 'c']))
  call assert_equal('/a/b/c', strager#path#join(['/', 'a/b/c']))
  call assert_equal('/a/b/c', strager#path#join(['/a', 'b/c']))
  call assert_equal('/a/b/c', strager#path#join(['/a/', 'b/c']))
  call assert_equal('/a/b/c', strager#path#join(['/a/b', 'c']))
  call assert_equal('/a/b/c', strager#path#join(['/a/b/', 'c']))

  " Join a relative path with a relative path.
  call assert_equal('a/b//c', strager#path#join(['a/b//', 'c']))
  call assert_equal('a/b/c', strager#path#join(['a', 'b/c']))
  call assert_equal('a/b/c', strager#path#join(['a/', 'b/c']))
  call assert_equal('a/b/c', strager#path#join(['a/b', 'c']))
  call assert_equal('a/b/c', strager#path#join(['a/b/', 'c']))

  " Join a relative path with an absolute path.
  call assert_equal('/b/c', strager#path#join(['a', '/b/c']))
  call assert_equal('/b/c', strager#path#join(['a/', '/b/c']))
  call assert_equal('/b/c', strager#path#join(['a//', '/b/c']))
  call assert_equal('/c', strager#path#join(['a/b', '/c']))
  call assert_equal('/c', strager#path#join(['a/b/', '/c']))
  call assert_equal('/c', strager#path#join(['a/b//', '/c']))
endfunction

function! Test_components_of_root_path()
  call assert_equal(['/'], strager#path#components('/'))
  call assert_equal(['//'], strager#path#components('//'))
endfunction

function! Test_components_of_absolute_path()
  call assert_equal(['/', 'hello'], strager#path#components('/hello'))
  call assert_equal(['/', 'hello', ''], strager#path#components('/hello/'))
  call assert_equal(['/', 'hello', 'world'], strager#path#components('/hello/world'))
  call assert_equal(['/', 'hello', 'world', ''], strager#path#components('/hello/world/'))
  call assert_equal(['//', 'hello'], strager#path#components('//hello'))
endfunction

function! Test_components_of_relative_path()
  call assert_equal(['hello'], strager#path#components('hello'))
  call assert_equal(['hello', ''], strager#path#components('hello/'))
  call assert_equal(['hello', 'world'], strager#path#components('hello/world'))
  call assert_equal(['hello', 'world', ''], strager#path#components('hello/world/'))
endfunction

function! Test_path_relative_to_itself_is_dot()
  call assert_equal('.', strager#path#make_relative('/path/to/dir/', '/path/to/dir/'))
  call assert_equal('.', strager#path#make_relative('/path/to/dir/', '/path/to/dir'))
  call assert_equal('.', strager#path#make_relative('/path/to/dir', '/path/to/dir/'))
  call assert_equal('.', strager#path#make_relative('/path/to/dir', '/path/to/dir'))
endfunction

function! Test_path_relative_to_root_strips_root()
  call assert_equal('my_file', strager#path#make_relative('/', '/my_file'))
  call assert_equal('my_dir/', strager#path#make_relative('/', '/my_dir/'))
  call assert_equal('mydir/myfile', strager#path#make_relative('/', '/mydir/myfile'))
endfunction

function! Test_path_relative_to_home_strips_home()
  call assert_equal('.vimrc', strager#path#make_relative('/home/strager', '/home/strager/.vimrc'))
  call assert_equal('.vim/', strager#path#make_relative('/home/strager', '/home/strager/.vim/'))
  call assert_equal('.vimrc', strager#path#make_relative('/home/strager/', '/home/strager/.vimrc'))
  call assert_equal('.vim/', strager#path#make_relative('/home/strager/', '/home/strager/.vim/'))
endfunction

function! Test_path_relative_to_unrelated_path_is_an_error()
  call s:assert_make_relative_throws('/a', '/b')
  call s:assert_make_relative_throws('/differentx/subdir/file', '/differenty/subdir/file')
  call s:assert_make_relative_throws('/long/ancestor/path', '/short')
  call s:assert_make_relative_throws('/short', '/long/descendant/path')
endfunction

function! Test_path_relative_to_descendant_is_an_error()
  call s:assert_make_relative_throws('/path/to/file', '/path/to')
  call s:assert_make_relative_throws('/path/to/file', '/path/to/')
endfunction

function! Test_paths_upward()
  call assert_equal(['/'], strager#path#paths_upward('/'))
  call assert_equal([
    \ '/path/to/file',
    \ '/path/to',
    \ '/path',
    \ '/',
  \ ], strager#path#paths_upward('/path/to/file'))
  call assert_equal([
    \ '/path/to/../from/dir',
    \ '/path/to/../from',
    \ '/path/to/..',
    \ '/path/to',
    \ '/path',
    \ '/',
  \ ], strager#path#paths_upward('/path/to/../from/dir'))
  call assert_equal([
    \ '/path/to/dir/',
    \ '/path/to/dir',
    \ '/path/to',
    \ '/path',
    \ '/',
  \ ], strager#path#paths_upward('/path/to/dir/'))
  call assert_equal([
    \ '/path/to/dir/.',
    \ '/path/to/dir',
    \ '/path/to',
    \ '/path',
    \ '/',
  \ ], strager#path#paths_upward('/path/to/dir/.'))

  call assert_equal(['path'], strager#path#paths_upward('path'))
  call assert_equal([
    \ 'path/to/file',
    \ 'path/to',
    \ 'path',
  \ ], strager#path#paths_upward('path/to/file'))
  call assert_equal([
    \ 'path/to/../from/dir',
    \ 'path/to/../from',
    \ 'path/to/..',
    \ 'path/to',
    \ 'path',
  \ ], strager#path#paths_upward('path/to/../from/dir'))
  call assert_equal([
    \ 'path/to/dir/',
    \ 'path/to/dir',
    \ 'path/to',
    \ 'path',
  \ ], strager#path#paths_upward('path/to/dir/'))
  call assert_equal([
    \ 'path/to/dir/.',
    \ 'path/to/dir',
    \ 'path/to',
    \ 'path',
  \ ], strager#path#paths_upward('path/to/dir/.'))

  call assert_equal(['.'], strager#path#paths_upward('.'))
  call assert_equal([
    \ './path/to/file',
    \ './path/to',
    \ './path',
    \ '.',
  \ ], strager#path#paths_upward('./path/to/file'))

  call assert_equal(['..'], strager#path#paths_upward('..'))
  call assert_equal([
    \ '../path/to/file',
    \ '../path/to',
    \ '../path',
    \ '..',
  \ ], strager#path#paths_upward('../path/to/file'))
endfunction

function! s:assert_make_relative_throws(ancestor_path, descendant_components)
  call strager#assert#assert_throws(
    \ {-> strager#path#make_relative(a:ancestor_path, a:descendant_components)},
    \ 'ES004',
  \ )
endfunction

function! Test_base_name_of_single_component_is_identity()
  call assert_equal('hello.txt', strager#path#base_name('hello.txt'))
endfunction

function! Test_base_name_of_single_component_with_trailing_slash_strips_slash()
  call assert_equal('hello_dir', strager#path#base_name('hello_dir/'))
  call assert_equal('hello_dir', strager#path#base_name('hello_dir///'))
endfunction

function! Test_base_name_of_relative_path_strips_parent_directories()
  call assert_equal('file.txt', strager#path#base_name('path/to/file.txt'))
  call assert_equal('file.txt', strager#path#base_name('/path/to/file.txt'))
  call assert_equal('file.txt', strager#path#base_name('path/to///file.txt'))
endfunction

function! Test_base_name_of_relative_path_with_trailing_slash_strips_parent_directories_and_trailing_slash()
  call assert_equal('directory', strager#path#base_name('path/to/directory/'))
  call assert_equal('directory', strager#path#base_name('/path/to/directory/'))
  call assert_equal('directory', strager#path#base_name('path/to///directory///'))
endfunction

call strager#test#run_all_tests()
