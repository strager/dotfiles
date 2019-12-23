function! Test_buffer_list_contains_file_buffers() abort
  %bwipeout!
  edit one.txt
  let l:one_buffer_number = bufnr('%')
  split two.txt
  let l:two_buffer_number = bufnr('%')
  split three.txt
  let l:three_buffer_number = bufnr('%')
  new

  let l:buffers = strager#search_buffers#get_searchable_buffers()
  call strager#assert#assert_contains(
    \ {'name': 'one.txt', 'number': l:one_buffer_number},
    \ l:buffers,
  \ )
  call strager#assert#assert_contains(
    \ {'name': 'two.txt', 'number': l:two_buffer_number},
    \ l:buffers,
  \ )
  call strager#assert#assert_contains(
    \ {'name': 'three.txt', 'number': l:three_buffer_number},
    \ l:buffers,
  \ )
endfunction

function! Test_buffer_list_contains_directory_buffers() abort
  %bwipeout!
  let l:test_directory = strager#file#make_directory_with_files([
    \ 'dir_a/hello.txt',
    \ 'dir_b/',
  \ ])
  execute printf('cd %s', fnameescape(l:test_directory))
  edit dir_a
  let l:dir_a_buffer_number = bufnr('%')
  split dir_b
  let l:dir_b_buffer_number = bufnr('%')
  new

  let l:buffers = strager#search_buffers#get_searchable_buffers()
  call strager#assert#assert_contains(
    \ {'name': 'dir_a/', 'number': l:dir_a_buffer_number},
    \ l:buffers,
  \ )
  call strager#assert#assert_contains(
    \ {'name': 'dir_b/', 'number': l:dir_b_buffer_number},
    \ l:buffers,
  \ )
endfunction

function! Test_buffer_list_contains_cousins_directory_buffers_of_cwd() abort
  %bwipeout!
  let l:test_directory = strager#file#make_directory_with_files([
    \ 'cwd_directory/hello.txt',
    \ 'uncle_directory/',
  \ ])
  execute printf('cd %s', fnameescape(strager#path#join([
    \ l:test_directory,
    \ 'cwd_directory',
  \ ])))
  let l:uncle_directory_path = strager#path#join([
    \ l:test_directory,
    \ 'uncle_directory',
  \ ])
  let l:uncle_directory_path = resolve(l:uncle_directory_path).'/'
  edit ../uncle_directory
  let l:uncle_directory_buffer_number = bufnr('%')
  new

  let l:buffers = strager#search_buffers#get_searchable_buffers()
  call strager#assert#assert_contains(
    \ {
      \ 'name': l:uncle_directory_path,
      \ 'number': l:uncle_directory_buffer_number,
    \ },
    \ l:buffers,
  \ )
endfunction

function! Test_buffer_list_does_not_contain_cwd_directory_buffer() abort
  %bwipeout!
  let l:test_directory = strager#file#make_directory_with_files([])
  execute printf('cd %s', fnameescape(l:test_directory))
  edit .
  new

  let l:buffers = strager#search_buffers#get_searchable_buffers()
  call assert_equal([], l:buffers)
endfunction

function! Test_buffer_list_does_not_contain_current_buffer() abort
  %bwipeout!
  edit one.txt
  split two.txt
  let l:current_buffer_number = bufnr('%')

  let l:buffers = strager#search_buffers#get_searchable_buffers()
  for l:buffer in l:buffers
    call assert_notequal(l:current_buffer_number, l:buffer.number)
    call assert_notequal('two.txt', l:buffer.name)
  endfor
endfunction

function! Test_buffer_list_does_not_contain_unnamed_buffers() abort
  %bwipeout!
  new
  new

  let l:buffers = strager#search_buffers#get_searchable_buffers()
  call assert_equal([], l:buffers)
endfunction

function! Test_buffer_list_does_not_contain_help_buffers() abort
  %bwipeout!
  let l:blank_buffer_number = bufnr('%')
  help windows.txt
  execute printf('%dbwipeout!', l:blank_buffer_number)
  tab help eval.txt

  let l:buffers = strager#search_buffers#get_searchable_buffers()
  call assert_equal([], l:buffers)
endfunction

function! Test_buffer_list_does_not_contain_quickfix_windows() abort
  %bwipeout!
  let l:blank_buffer_number = bufnr('%')
  copen
  let l:quickfix_buffer_number = bufnr('%')
  execute printf('%dbwipeout!', l:blank_buffer_number)
  new

  let l:buffers = strager#search_buffers#get_searchable_buffers()
  call assert_equal([], l:buffers)
endfunction

function! Test_buffer_list_does_not_contain_terminal_buffers() abort
  %bwipeout!
  let l:blank_buffer_number = bufnr('%')
  term
  let l:terminal_buffer_number = bufnr('%')
  execute printf('%dbwipeout!', l:blank_buffer_number)
  new

  let l:buffers = strager#search_buffers#get_searchable_buffers()
  call assert_equal([], l:buffers)
endfunction

function! Test_buffer_list_does_not_contain_unlisted_file_buffers() abort
  %bwipeout!
  edit unlisted.txt
  let l:unlisted_buffer_number = bufnr('%')
  new
  execute printf('bdelete %d', l:unlisted_buffer_number)
  call assert_equal(
    \ 'unlisted.txt',
    \ bufname(l:unlisted_buffer_number),
    \ 'Unlisted buffer should still exist',
  \ )
  call assert_false(
    \ buflisted(l:unlisted_buffer_number),
    \ 'Buffer should be unlisted',
  \ )

  let l:buffers = strager#search_buffers#get_searchable_buffers()
  call assert_equal([], l:buffers)
endfunction

function! Test_fzf_header_contains_name_of_current_buffer_file() abort
  %bwipeout!
  edit hello.txt

  let l:run_options = s:fzf_run_options()
  call assert_equal(['hello.txt'], strager#fzf#header_lines(l:run_options))
endfunction

function! Test_fzf_header_contains_name_of_current_directory_file() abort
  %bwipeout!
  let l:test_directory = strager#file#make_directory_with_files([
    \ 'subdirectory/'
  \ ])
  execute printf('cd %s', fnameescape(l:test_directory))
  edit subdirectory

  let l:run_options = s:fzf_run_options()
  call assert_equal(['subdirectory/'], strager#fzf#header_lines(l:run_options))
endfunction

function! Test_fzf_header_contains_noname_if_current_buffer_is_unnamed() abort
  %bwipeout!
  normal! ihello

  let l:run_options = s:fzf_run_options()
  call assert_equal(['[No Name]'], strager#fzf#header_lines(l:run_options))
endfunction

function! Test_fzf_header_contains_help_name_if_current_buffer_is_help() abort
  %bwipeout!
  help undo.txt

  let l:run_options = s:fzf_run_options()
  call assert_equal(
    \ ['undo.txt [Help]'],
    \ strager#fzf#header_lines(l:run_options),
  \ )
endfunction

function! Test_fzf_shows_newest_buffers_first() abort
  %bwipeout!
  edit a.txt
  split b.txt
  split c.txt
  new

  let l:run_options = s:fzf_run_options()
  call assert_equal(
    \ ['c.txt', 'b.txt', 'a.txt'],
    \ strager#fzf#presented_lines(l:run_options),
  \ )
endfunction

function! Test_fzf_shows_files_before_directories() abort
  %bwipeout!
  let l:test_directory = strager#file#make_directory_with_files([
    \ 'dir_a/',
    \ 'dir_b/',
    \ 'file_a.txt',
    \ 'file_b.txt',
  \ ])
  execute printf('cd %s', fnameescape(l:test_directory))
  edit dir_a
  split file_a.txt
  split dir_b
  split file_b.txt
  new

  let l:run_options = s:fzf_run_options()
  call assert_equal(
    \ ['file_b.txt', 'file_a.txt', 'dir_b/', 'dir_a/'],
    \ strager#fzf#presented_lines(l:run_options),
  \ )
endfunction

function! Test_fzf_shows_buffer_names_with_spaces() abort
  %bwipeout!
  edit hello world  .txt
  new

  let l:run_options = s:fzf_run_options()
  call assert_equal(
    \ ['hello world  .txt'],
    \ strager#fzf#presented_lines(l:run_options),
  \ )
endfunction

function! Test_cancelling_fzf_does_not_change_current_window() abort
  %bwipeout!
  edit a.txt
  edit b.txt
  let l:b_buffer_number = bufnr('%')
  let l:window_id = win_getid()

  let l:run_options = s:fzf_run_options()
  call strager#fzf#call_sink(l:run_options, [])

  call assert_equal(
    \ l:b_buffer_number,
    \ winbufnr(l:window_id),
    \ 'Window should show the same buffer as before',
  \ )
endfunction

function! Test_selecting_file_in_fzf_changes_current_window() abort
  %bwipeout!
  edit a.txt
  let l:a_buffer_number = bufnr('%')
  edit b.txt
  edit c.txt
  let l:c_buffer_number = bufnr('%')
  let l:window_id = win_getid()

  let l:run_options = s:fzf_run_options()
  let l:input_line = strager#fzf#input_lines(l:run_options)[-1]
  call strager#fzf#call_sink(l:run_options, [l:input_line])

  let l:new_buffer_number = winbufnr(l:window_id)
  call assert_notequal(
    \ l:c_buffer_number,
    \ l:new_buffer_number,
    \ 'Window should show a different buffer',
  \ )
  call assert_equal(
    \ l:a_buffer_number,
    \ l:new_buffer_number,
    \ 'Window should show a.txt',
  \ )
endfunction

function! Test_selecting_directory_in_fzf_changes_current_window() abort
  %bwipeout!
  let l:test_directory = strager#file#make_directory_with_files(['dir/'])
  execute printf('cd %s', fnameescape(l:test_directory))
  edit dir
  let l:dir_buffer_number = bufnr('%')
  split file.txt
  let l:file_buffer_number = bufnr('%')
  let l:window_id = win_getid()

  let l:run_options = s:fzf_run_options()
  let l:input_line = strager#fzf#input_lines(l:run_options)[-1]
  call strager#fzf#call_sink(l:run_options, [l:input_line])

  let l:new_buffer_number = winbufnr(l:window_id)
  call assert_notequal(
    \ l:file_buffer_number,
    \ l:new_buffer_number,
    \ 'Window should show a different buffer',
  \ )
  call assert_equal(
    \ l:dir_buffer_number,
    \ l:new_buffer_number,
    \ 'Window should show dir/',
  \ )
endfunction

function! Test_selecting_buffer_with_possibly_ambiguous_name_opens_exact_match() abort
  %bwipeout!
  let l:test_directory = strager#file#make_directory_with_files([
    \ 'file',
    \ 'file_longer',
    \ 'file_longer_longest',
  \ ])
  execute printf('cd %s', fnameescape(l:test_directory))
  edit file
  let l:file_buffer_number = bufnr('%')
  split file_longer
  let l:file_longer_buffer_number = bufnr('%')
  split file_longer_longest
  let l:file_longer_longest_buffer_number = bufnr('%')
  new

  let l:run_options = s:fzf_run_options()
  call strager#fzf#call_sink(
    \ l:run_options,
    \ [s:match_fzf_line(l:run_options, 'file_longer\(_longest\)\@!')],
  \ )

  let l:new_buffer_number = bufnr('%')
  call assert_notequal(
    \ l:file_buffer_number,
    \ l:new_buffer_number,
    \ 'The new buffer should not be a buffer whose name is shorter than the selection',
  \ )
  call assert_notequal(
    \ l:file_longer_longest_buffer_number,
    \ l:new_buffer_number,
    \ 'The new buffer should not be a buffer whose name is longer than the selection',
  \ )
  call assert_equal(
    \ l:file_longer_buffer_number,
    \ l:new_buffer_number,
    \ 'The new buffer should be a buffer whose name exactly matches the selection',
  \ )
endfunction

function! Test_selecting_directory_buffer_if_children_are_also_available_opens_directory() abort
  %bwipeout!
  let l:test_directory = strager#file#make_directory_with_files([
    \ 'subdirectory/file_a.txt',
    \ 'subdirectory/file_b.txt',
  \ ])
  execute printf('cd %s', fnameescape(l:test_directory))
  edit subdirectory
  let l:subdirectory_buffer_number = bufnr('%')
  split subdirectory/file_a.txt
  let l:file_a_buffer_number = bufnr('%')
  split subdirectory/file_b.txt
  let l:file_b_buffer_number = bufnr('%')
  new

  let l:run_options = s:fzf_run_options()
  call strager#fzf#call_sink(
    \ l:run_options,
    \ [s:match_fzf_line(l:run_options, 'subdirectory/\(file\)\@!')],
  \ )

  let l:new_buffer_number = bufnr('%')
  call assert_notequal(
    \ l:file_a_buffer_number,
    \ l:new_buffer_number,
    \ 'The new buffer should not be a child of the selected directory',
  \ )
  call assert_notequal(
    \ l:file_b_buffer_number,
    \ l:new_buffer_number,
    \ 'The new buffer should not be a child of the selected directory',
  \ )
  call assert_equal(
    \ l:subdirectory_buffer_number,
    \ l:new_buffer_number,
    \ 'The new buffer should be the selected directory',
  \ )
endfunction

function! Test_selecting_unlisted_directory_in_fzf_reloads_directory() abort
  %bwipeout!
  let l:test_directory = strager#file#make_directory_with_files([
    \ 'dir/file_a.txt',
  \ ])
  execute printf('cd %s', fnameescape(l:test_directory))
  edit dir
  edit file.txt

  call writefile([], 'dir/file_b.txt')
  let l:run_options = s:fzf_run_options()
  let l:input_line = strager#fzf#input_lines(l:run_options)[-1]
  call strager#fzf#call_sink(l:run_options, [l:input_line])

  call assert_equal(
    \ ['dir/file_a.txt', 'dir/file_b.txt'],
    \ strager#buffer#get_current_buffer_lines(),
  \ )
endfunction

function! s:fzf_run_options() abort
  return strager#search_buffers#get_fzf_run_options_for_searching_buffers()
endfunction

function! s:match_fzf_lines(fzf_run_options, pattern) abort
  let l:presented_lines = strager#fzf#presented_lines(a:fzf_run_options)
  let l:input_lines = strager#fzf#input_lines(a:fzf_run_options)
  call filter(
    \ l:input_lines,
    \ {index, _ -> match(l:presented_lines[index], a:pattern) != -1},
  \ )
  return l:input_lines
endfunction

function! s:match_fzf_line(fzf_run_options, pattern) abort
  let l:lines = s:match_fzf_lines(a:fzf_run_options, a:pattern)
  if len(l:lines) != 1
    if l:lines ==# []
      throw printf('No lines matched pattern %s', string(a:pattern))
    else
      throw printf('Too many lines matched pattern %s', string(a:pattern))
    endif
  endif
  return l:lines[0]
endfunction

call strager#test#run_all_tests()
