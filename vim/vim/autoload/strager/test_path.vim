" FIXME(strager): How should strager#path#join and strager#path#components
" relate?

function! Test_join_posix_paths() abort
  " Join with an empty string.
  call assert_equal('', strager#path#join_posix(['', '']))
  call assert_equal('.', strager#path#join_posix(['.', '']))
  call assert_equal('/', strager#path#join_posix(['', '/']))
  call assert_equal('/', strager#path#join_posix(['/', '']))
  call assert_equal('a', strager#path#join_posix(['', 'a']))
  call assert_equal('a', strager#path#join_posix(['a', '']))
  call assert_equal('a/', strager#path#join_posix(['', 'a/']))
  call assert_equal('a/', strager#path#join_posix(['a/', '']))
  call assert_equal('a//', strager#path#join_posix(['', 'a//']))
  call assert_equal('a//', strager#path#join_posix(['a//', '']))

  " Join an absolute path with a relative path.
  call assert_equal('//a/b/c', strager#path#join_posix(['//', 'a/b/c']))
  call assert_equal('/a//b/c', strager#path#join_posix(['/a//', 'b/c']))
  call assert_equal('/a/b//c', strager#path#join_posix(['/a/b//', 'c']))
  call assert_equal('/a/b/c', strager#path#join_posix(['/', 'a/b/c']))
  call assert_equal('/a/b/c', strager#path#join_posix(['/a', 'b/c']))
  call assert_equal('/a/b/c', strager#path#join_posix(['/a/', 'b/c']))
  call assert_equal('/a/b/c', strager#path#join_posix(['/a/b', 'c']))
  call assert_equal('/a/b/c', strager#path#join_posix(['/a/b/', 'c']))

  " Join a relative path with a relative path.
  call assert_equal('a/b//c', strager#path#join_posix(['a/b//', 'c']))
  call assert_equal('a/b/c', strager#path#join_posix(['a', 'b/c']))
  call assert_equal('a/b/c', strager#path#join_posix(['a/', 'b/c']))
  call assert_equal('a/b/c', strager#path#join_posix(['a/b', 'c']))
  call assert_equal('a/b/c', strager#path#join_posix(['a/b/', 'c']))

  " Join a relative path with an absolute path.
  call assert_equal('/b/c', strager#path#join_posix(['a', '/b/c']))
  call assert_equal('/b/c', strager#path#join_posix(['a/', '/b/c']))
  call assert_equal('/b/c', strager#path#join_posix(['a//', '/b/c']))
  call assert_equal('/c', strager#path#join_posix(['a/b', '/c']))
  call assert_equal('/c', strager#path#join_posix(['a/b/', '/c']))
  call assert_equal('/c', strager#path#join_posix(['a/b//', '/c']))
endfunction

function! Test_components_of_root_path() abort
  call assert_equal(['/'], strager#path#components('/'))
  call assert_equal(['//'], strager#path#components('//'))
endfunction

function! Test_components_of_absolute_path() abort
  call assert_equal(['/', 'hello'], strager#path#components('/hello'))
  call assert_equal(['/', 'hello', ''], strager#path#components('/hello/'))
  call assert_equal(['/', 'hello', 'world'], strager#path#components('/hello/world'))
  call assert_equal(['/', 'hello', 'world', ''], strager#path#components('/hello/world/'))
  call assert_equal(['//', 'hello'], strager#path#components('//hello'))
endfunction

function! Test_components_of_relative_path() abort
  call assert_equal(['hello'], strager#path#components('hello'))
  call assert_equal(['hello', ''], strager#path#components('hello/'))
  call assert_equal(['hello', 'world'], strager#path#components('hello/world'))
  call assert_equal(['hello', 'world', ''], strager#path#components('hello/world/'))
endfunction

function! Test_join_windows_paths() abort
  " Join with an empty string.
  call assert_equal('', strager#path#join_windows(['', '']))
  call assert_equal('.', strager#path#join_windows(['.', '']))
  call assert_equal('\', strager#path#join_windows(['', '\']))
  call assert_equal('\', strager#path#join_windows(['\', '']))
  call assert_equal('c:\', strager#path#join_windows(['', 'c:\']))
  call assert_equal('c:\', strager#path#join_windows(['c:\', '']))
  call assert_equal('/', strager#path#join_windows(['', '/']))
  call assert_equal('/', strager#path#join_windows(['/', '']))
  call assert_equal('a', strager#path#join_windows(['', 'a']))
  call assert_equal('a', strager#path#join_windows(['a', '']))
  call assert_equal('a/', strager#path#join_windows(['', 'a/']))
  call assert_equal('a/', strager#path#join_windows(['a/', '']))
  call assert_equal('a//', strager#path#join_windows(['', 'a//']))
  call assert_equal('a//', strager#path#join_windows(['a//', '']))
  call assert_equal('a\', strager#path#join_windows(['', 'a\']))
  call assert_equal('a\', strager#path#join_windows(['a\', '']))
  call assert_equal('a\\', strager#path#join_windows(['', 'a\\']))
  call assert_equal('a\\', strager#path#join_windows(['a\\', '']))

  " Join an absolute path with a relative path.
  call assert_equal('\a\\b\c', strager#path#join_windows(['\a\\', 'b\c']))
  call assert_equal('\a\b\\c', strager#path#join_windows(['\a\b\\', 'c']))
  call assert_equal('\a\b\c', strager#path#join_windows(['\', 'a\b\c']))
  call assert_equal('\a\b\c', strager#path#join_windows(['\a', 'b\c']))
  call assert_equal('\a\b\c', strager#path#join_windows(['\a\', 'b\c']))
  call assert_equal('\a\b\c', strager#path#join_windows(['\a\b', 'c']))
  call assert_equal('\a\b\c', strager#path#join_windows(['\a\b\', 'c']))

  " Join a drive path with a relative path.
  call assert_equal('c:\a\\b\c', strager#path#join_windows(['c:\a\\', 'b\c']))
  call assert_equal('c:\a\b\\c', strager#path#join_windows(['c:\a\b\\', 'c']))
  call assert_equal('c:\a\b\c', strager#path#join_windows(['c:', 'a\b\c']))
  call assert_equal('c:\a\b\c', strager#path#join_windows(['c:\', 'a\b\c']))
  call assert_equal('c:\a\b\c', strager#path#join_windows(['c:\a', 'b\c']))
  call assert_equal('c:\a\b\c', strager#path#join_windows(['c:\a\', 'b\c']))
  call assert_equal('c:\a\b\c', strager#path#join_windows(['c:\a\b', 'c']))
  call assert_equal('c:\a\b\c', strager#path#join_windows(['c:\a\b\', 'c']))

  " Join a relative path with a relative path.
  call assert_equal('a\b\\c', strager#path#join_windows(['a\b\\', 'c']))
  call assert_equal('a\b\c', strager#path#join_windows(['a', 'b\c']))
  call assert_equal('a\b\c', strager#path#join_windows(['a\', 'b\c']))
  call assert_equal('a\b\c', strager#path#join_windows(['a\b', 'c']))
  call assert_equal('a\b\c', strager#path#join_windows(['a\b\', 'c']))
  " Forward slashes are preserved.
  call assert_equal('a\b/c', strager#path#join_windows(['a', 'b/c']))
  call assert_equal('a/b\c', strager#path#join_windows(['a/b', 'c']))
  call assert_equal('a/b/c', strager#path#join_windows(['a/b/', 'c']))

  " Join a relative path with an absolute path.
  call assert_equal('\b\c', strager#path#join_windows(['a', '\b\c']))
  call assert_equal('\b\c', strager#path#join_windows(['a\', '\b\c']))
  call assert_equal('\b\c', strager#path#join_windows(['a\\', '\b\c']))
  call assert_equal('\c', strager#path#join_windows(['a\b', '\c']))
  call assert_equal('\c', strager#path#join_windows(['a\b\', '\c']))
  call assert_equal('\c', strager#path#join_windows(['a\b\\', '\c']))
  " Forward slashes are preserved.
  call assert_equal('/b/c', strager#path#join_windows(['a', '/b/c']))

  " Join a relative path with a drive path.
  call assert_equal('c:\b\c', strager#path#join_windows(['a', 'c:\b\c']))
  call assert_equal('c:\b\c', strager#path#join_windows(['a\', 'c:\b\c']))
  call assert_equal('c:\b\c', strager#path#join_windows(['a\\', 'c:\b\c']))
  call assert_equal('c:\', strager#path#join_windows(['a\b', 'c:\']))
  call assert_equal('c:', strager#path#join_windows(['a\b', 'c:']))
  call assert_equal('c:\c', strager#path#join_windows(['a\b', 'c:\c']))
  call assert_equal('c:\c', strager#path#join_windows(['a\b\', 'c:\c']))
  call assert_equal('c:\c', strager#path#join_windows(['a\b\\', 'c:\c']))
  " Forward slashes are preserved.
  call assert_equal('c:/b/c', strager#path#join_windows(['a', 'c:/b/c']))
endfunction

function! Test_components_of_root_posix_path() abort
  call assert_equal(['/'], strager#path#components_posix('/'))
  call assert_equal(['//'], strager#path#components_posix('//'))
endfunction

function! Test_components_of_root_windows_path() abort
  call assert_equal(['/'], strager#path#components_windows('/'))
  call assert_equal(['\'], strager#path#components_windows('\'))
  call assert_equal(['c:'], strager#path#components_windows('c:'))
  call assert_equal(['c:', ''], strager#path#components_windows('c:\'))
endfunction

function! Test_components_of_absolute_posix_path() abort
  call assert_equal(['/', 'hello'], strager#path#components_posix('/hello'))
  call assert_equal(['/', 'hello', ''], strager#path#components_posix('/hello/'))
  call assert_equal(['/', 'hello', 'world'], strager#path#components_posix('/hello/world'))
  call assert_equal(['/', 'hello', 'world', ''], strager#path#components_posix('/hello/world/'))
  call assert_equal(['//', 'hello'], strager#path#components_posix('//hello'))
endfunction

function! Test_components_of_absolute_windows_path() abort
  call assert_equal(['\', 'hello'], strager#path#components_windows('\hello'))
  call assert_equal(['\', 'hello', ''], strager#path#components_windows('\hello\'))
  call assert_equal(['\', 'hello', 'world'], strager#path#components_windows('\hello\world'))
  call assert_equal(['\', 'hello', 'world', ''], strager#path#components_windows('\hello\world\'))

  call assert_equal(['/', 'hello'], strager#path#components_windows('/hello'))
  call assert_equal(['/', 'hello', ''], strager#path#components_windows('/hello/'))
  call assert_equal(['/', 'hello', 'world'], strager#path#components_windows('/hello/world'))
  call assert_equal(['/', 'hello', 'world', ''], strager#path#components_windows('/hello/world/'))
endfunction

function! Test_components_of_absolute_windows_drive_path() abort
  call assert_equal(['c:', 'hello'], strager#path#components_windows('c:\hello'))
  call assert_equal(['c:', 'hello', ''], strager#path#components_windows('c:\hello\'))
  call assert_equal(['c:', 'hello', 'world'], strager#path#components_windows('c:\hello\world'))
  call assert_equal(['c:', 'hello', 'world', ''], strager#path#components_windows('c:\hello\world\'))
endfunction

function! Test_components_of_relative_posix_path() abort
  call assert_equal(['hello'], strager#path#components_posix('hello'))
  call assert_equal(['hello', ''], strager#path#components_posix('hello/'))
  call assert_equal(['hello', 'world'], strager#path#components_posix('hello/world'))
  call assert_equal(['hello', 'world', ''], strager#path#components_posix('hello/world/'))
endfunction

function! Test_components_of_relative_windows_path() abort
  call assert_equal(['hello'], strager#path#components_windows('hello'))
  call assert_equal(['hello', ''], strager#path#components_windows('hello\'))
  call assert_equal(['hello', 'world'], strager#path#components_windows('hello\world'))
  call assert_equal(['hello', 'world', ''], strager#path#components_windows('hello\world\'))
endfunction

function! Test_path_relative_to_itself_is_dot() abort
  call assert_equal('.', strager#path#make_relative('/path/to/dir/', '/path/to/dir/'))
  call assert_equal('.', strager#path#make_relative('/path/to/dir/', '/path/to/dir'))
  call assert_equal('.', strager#path#make_relative('/path/to/dir', '/path/to/dir/'))
  call assert_equal('.', strager#path#make_relative('/path/to/dir', '/path/to/dir'))
endfunction

function! Test_path_relative_to_root_strips_root() abort
  call assert_equal('my_file', strager#path#make_relative('/', '/my_file'))
  if has('win32')
    " TODO(strager): Preserve forward slashes on Windows.
    call assert_equal('my_dir\', strager#path#make_relative('/', '/my_dir/'))
    call assert_equal('mydir\myfile', strager#path#make_relative('/', '/mydir/myfile'))
  else
    call assert_equal('my_dir/', strager#path#make_relative('/', '/my_dir/'))
    call assert_equal('mydir/myfile', strager#path#make_relative('/', '/mydir/myfile'))
  endif
endfunction

function! Test_windows_path_relative_to_drive_strips_root() abort
  call assert_equal('my_file', strager#path#make_relative_windows('c:\', 'c:\my_file'))
  call assert_equal('mydir\myfile', strager#path#make_relative_windows('c:\', 'c:\mydir\myfile'))
endfunction

function! Test_windows_path_relative_preserves_trailing_slash() abort
  call assert_equal('my_dir\', strager#path#make_relative_windows('\', '\my_dir\'))
endfunction

function! Test_path_relative_to_home_strips_home() abort
  call assert_equal('.vimrc', strager#path#make_relative('/home/strager', '/home/strager/.vimrc'))
  call assert_equal('.vimrc', strager#path#make_relative('/home/strager/', '/home/strager/.vimrc'))
  if has('win32')
    " TODO(strager): Preserve forward slashes on Windows.
    call assert_equal('.vim\', strager#path#make_relative('/home/strager', '/home/strager/.vim/'))
    call assert_equal('.vim\', strager#path#make_relative('/home/strager/', '/home/strager/.vim/'))
  else
    call assert_equal('.vim/', strager#path#make_relative('/home/strager', '/home/strager/.vim/'))
    call assert_equal('.vim/', strager#path#make_relative('/home/strager/', '/home/strager/.vim/'))
  endif
endfunction

function! Test_path_relative_to_unrelated_path_is_an_error() abort
  call s:assert_make_relative_throws('/a', '/b')
  call s:assert_make_relative_throws('/differentx/subdir/file', '/differenty/subdir/file')
  call s:assert_make_relative_throws('/long/ancestor/path', '/short')
  call s:assert_make_relative_throws('/short', '/long/descendant/path')
  if has('win32')
    call s:assert_make_relative_throws('c:\a\b', 'c:\c\d')
    call s:assert_make_relative_throws('d:\', 'c:\abc')
  endif
endfunction

function! Test_path_relative_to_descendant_is_an_error() abort
  call s:assert_make_relative_throws('/path/to/file', '/path/to')
  call s:assert_make_relative_throws('/path/to/file', '/path/to/')
endfunction

function! Test_paths_upward() abort
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

if has('win32')
  function! Test_paths_upward_windows() abort
    call assert_equal(['c:\'], strager#path#paths_upward('c:\'))
    call assert_equal(['C:\'], strager#path#paths_upward('C:\'))
    call assert_equal(['X:'], strager#path#paths_upward('X:'))
    call assert_equal([
      \ 'c:/path/to/file',
      \ 'c:/path/to',
      \ 'c:/path',
      \ 'c:/',
    \ ], strager#path#paths_upward('c:/path/to/file'))
  endfunction
endif

function! s:assert_make_relative_throws(ancestor_path, descendant_components) abort
  call strager#assert#assert_throws(
    \ {-> strager#path#make_relative(a:ancestor_path, a:descendant_components)},
    \ 'ES004',
  \ )
endfunction

function! Test_base_name_of_single_component_is_identity() abort
  call assert_equal('hello.txt', strager#path#base_name('hello.txt'))
endfunction

function! Test_base_name_of_single_component_with_trailing_slash_strips_slash() abort
  call assert_equal('hello_dir', strager#path#base_name('hello_dir/'))
  call assert_equal('hello_dir', strager#path#base_name('hello_dir///'))
endfunction

function! Test_base_name_of_relative_path_strips_parent_directories() abort
  call assert_equal('file.txt', strager#path#base_name('path/to/file.txt'))
  call assert_equal('file.txt', strager#path#base_name('/path/to/file.txt'))
  call assert_equal('file.txt', strager#path#base_name('path/to///file.txt'))
endfunction

function! Test_base_name_of_relative_path_with_trailing_slash_strips_parent_directories_and_trailing_slash() abort
  call assert_equal('directory', strager#path#base_name('path/to/directory/'))
  call assert_equal('directory', strager#path#base_name('/path/to/directory/'))
  call assert_equal('directory', strager#path#base_name('path/to///directory///'))
endfunction

call strager#test#run_all_tests()
