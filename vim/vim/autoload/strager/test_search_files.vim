function! Test_file_list_contains_child_and_grandchild_files_of_cwd()
  let l:test_directory = strager#file#make_directory_with_files([
    \ 'file.txt',
    \ 'subdirectory/other.txt',
  \ ])
  execute printf('cd %s', fnameescape(l:test_directory))

  let l:run_options = s:fzf_run_options()
  let l:lines = strager#fzf#presented_lines(l:run_options)
  call strager#assert#assert_contains('file.txt', l:lines)
  call strager#assert#assert_contains('subdirectory/other.txt', l:lines)
  call assert_equal(2, len(l:lines))
endfunction

function! Test_prompt_is_shortened_cwd()
  let l:test_directory = strager#file#make_directory_with_files([])
  execute printf('cd %s', fnameescape(l:test_directory))

  let l:run_options = s:fzf_run_options()
  let l:prompt = strager#fzf#prompt(l:run_options)
  call assert_match('/$', l:prompt, 'Prompt must end in /')
  call assert_match(
    \ s:shortened_absolute_path_pattern,
    \ l:prompt,
    \ 'Leading path components must be shortened',
  \ )
  call assert_equal(
    \ strager#path#base_name(l:test_directory),
    \ strager#path#base_name(l:prompt),
    \ 'Last component must be unshortened',
  \ )
endfunction

function! Test_prompt_is_slash_if_cwd_is_exactly_root()
  cd /
  let l:run_options = s:fzf_run_options()
  let l:prompt = strager#fzf#prompt(l:run_options)
  call assert_equal('/', l:prompt, 'Prompt must be /')
endfunction

function! Test_prompt_is_tilde_slash_if_cwd_is_exactly_home_directory()
  cd ~
  let l:run_options = s:fzf_run_options()
  let l:prompt = strager#fzf#prompt(l:run_options)
  call assert_equal('~/', l:prompt, 'Prompt must shorten home directory')
endfunction

function! Test_prompt_starts_with_tilde_if_cwd_is_in_home_directory()
  cd ~/.vim/autoload/strager/
  let l:run_options = s:fzf_run_options()
  let l:prompt = strager#fzf#prompt(l:run_options)
  call assert_match('^\~/', l:prompt, 'Prompt must shorten home directory')
endfunction

function! Test_selecting_file_opens_file_in_current_window()
  let l:test_directory = strager#file#make_directory_with_files([
    \ ['hello.txt', 'file content here'],
    \ ['world.txt', 'file content here'],
  \ ])
  execute printf('cd %s', fnameescape(l:test_directory))
  edit doesnotexist.txt
  let l:temporary_buffer_number = bufnr('%')
  let l:window_id = win_getid()

  let l:run_options = s:fzf_run_options()
  call strager#fzf#call_sink(l:run_options, [])

  call assert_equal(
    \ l:temporary_buffer_number,
    \ winbufnr(l:window_id),
    \ 'Window should show the same buffer as before',
  \ )
endfunction

function! Test_shortened_absolute_path()
  call assert_true(
    \ s:is_shortened_absolute_path('/a/b/c/'),
    \ 'Path relative to root is absolute',
  \ )
  call assert_true(
    \ s:is_shortened_absolute_path('/a/b/c'),
    \ 'Path relative to root is absolute',
  \ )
  call assert_true(
    \ s:is_shortened_absolute_path('~/a/b/c'),
    \ 'Path relative to home dir is absolute',
  \ )
  call assert_true(
    \ s:is_shortened_absolute_path('~/a/b/c/'),
    \ 'Path relative to home dir is absolute',
  \ )
  call assert_true(
    \ s:is_shortened_absolute_path('/a/b/hello'),
    \ 'Path with long final component is shortened',
  \ )
  call assert_true(
    \ s:is_shortened_absolute_path('/a/b/hello/'),
    \ 'Path with long final component is shortened',
  \ )

  call assert_false(
    \ s:is_shortened_absolute_path('a/b/c/'),
    \ 'Relative paths are not absolute',
  \ )
  call assert_false(
    \ s:is_shortened_absolute_path('/hello/b/c/'),
    \ 'Path with long leading component is not shortened',
  \ )
  call assert_false(
    \ s:is_shortened_absolute_path('/a/hello/c/'),
    \ 'Path with long leading component is not shortened',
  \ )
  call assert_false(
    \ s:is_shortened_absolute_path('/a//b/c/'),
    \ 'Path with redundant component separators is not shortened',
  \ )
  call assert_false(
    \ s:is_shortened_absolute_path('/a///b/c/'),
    \ 'Path with redundant component separators is not shortened',
  \ )
  call assert_false(
    \ s:is_shortened_absolute_path('/a/b/c//'),
    \ 'Path with redundant component separators is not shortened',
  \ )
  call assert_false(
    \ s:is_shortened_absolute_path('/a/b/c///'),
    \ 'Path with redundant component separators is not shortened',
  \ )
endfunction

function! s:is_shortened_absolute_path(path)
  return match(a:path, s:shortened_absolute_path_pattern) != -1
endfunction

let s:shortened_absolute_path_pattern = '^\~\?/\%([^/]/\)*[^/]\+/\?$'

function! s:fzf_run_options()
  return strager#search_files#get_fzf_run_options_for_searching_files()
endfunction

call strager#test#run_all_tests()
