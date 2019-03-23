" TODO(strager): D key should delete directories.
" TODO(strager): R key should move files and directories.

function! Test_browser_lists_files()
  call s:set_up_project(['my_file', 'another_file'])
  edit .
  let l:names = strager#buffer#get_current_buffer_lines()
  call sort(l:names)
  call assert_equal(['another_file', 'my_file'], l:names)
endfunction

function! Test_browser_lists_directories_with_trailing_slash()
  call s:set_up_project(['subdir/', 'another_subdir/'])
  edit .
  let l:names = strager#buffer#get_current_buffer_lines()
  call sort(l:names)
  call assert_equal(['another_subdir/', 'subdir/'], l:names)
endfunction

function! Test_browser_lists_symlinks_to_files()
  call s:set_up_project(['file'])
  call strager#file#create_symbolic_link('file', 'symlink_to_file')
  edit .
  let l:names = strager#buffer#get_current_buffer_lines()
  call sort(l:names)
  call assert_equal(['file', 'symlink_to_file'], l:names)
endfunction

function! Test_browser_lists_symlinks_to_directories()
  call s:set_up_project(['dir/'])
  call strager#file#create_symbolic_link('dir', 'symlink_to_dir')
  edit .
  let l:names = strager#buffer#get_current_buffer_lines()
  call sort(l:names)
  call assert_equal(['dir/', 'symlink_to_dir/'], l:names)
endfunction

function! Test_browser_lists_broken_symlinks()
  call s:set_up_project([])
  call strager#file#create_symbolic_link('does_not_exist', 'symlink')
  edit .
  let l:names = strager#buffer#get_current_buffer_lines()
  call assert_equal(['symlink'], l:names)
endfunction

function! Test_enter_opens_file_under_cursor()
  call s:set_up_project(['myfile.txt'])
  edit .
  /myfile
  execute "normal \<CR>"
  call assert_equal('myfile.txt', s:get_relative_path_of_current_buffer())
endfunction

function! Test_enter_in_subdirectory_opens_file_under_cursor()
  call s:set_up_project(['project/myfile.txt', 'project/subdir/myfile.txt'])
  edit project/subdir
  /myfile
  execute "normal \<CR>"
  call assert_equal(
    \ 'project/subdir/myfile.txt',
    \ s:get_relative_path_of_current_buffer(),
  \ )
endfunction

function! Test_enter_key_opens_directory_under_cursor()
  call s:set_up_project(['subdir/myfile.txt'])
  edit .
  /sub
  execute "normal \<CR>"
  call assert_equal('subdir/', s:get_relative_path_of_current_buffer())
endfunction

function! Test_percent_key_prompts_file_name_then_opens_it()
  call s:set_up_project([])
  edit .
  execute "normal %hello.txt\<CR>"
  call assert_equal('hello.txt', s:get_relative_path_of_current_buffer())
endfunction

function! Test_d_key_prompts_directory_name_then_creates_it()
  call s:set_up_project([])
  edit .
  execute "normal dmydir\<CR>"
  call assert_true(isdirectory('mydir'))
endfunction

function! Test_mkdir_creates_nested_directories()
  call s:set_up_project([])
  let l:old_cwd = getcwd()
  edit .
  execute "normal dmydir/subdir/otherdir\<CR>"
  call assert_true(isdirectory('mydir'))
  call assert_true(isdirectory('mydir/subdir'))
  call assert_true(isdirectory('mydir/subdir/otherdir'))
endfunction

function! Test_mkdir_moves_cursor_to_created_directory()
  call s:set_up_project(["a/", "x/"])
  edit .
  1
  execute "normal dnew_dir\<CR>"
  call assert_equal('new_dir/', getline('.'))
endfunction

function! Test_mkdir_of_nested_directories_moves_cursor_to_created_child_directory()
  call s:set_up_project(["a/", "x/"])
  edit .
  1
  execute "normal dnew_dir/subdir\<CR>"
  call assert_equal('new_dir/', getline('.'))
endfunction

function! Test_mkdir_of_cousin_directory_does_not_move_cursor()
  call s:set_up_project([
    \ "subdir/a",
    \ "subdir/b",
    \ "subdir/c",
    \ "subdir/d",
    \ "other_subdir/",
  \ ])
  edit subdir
  3
  execute "normal d../other_subdir/a\<CR>"
  let [l:_bufnum, l:lnum, l:_col, l:_off, l:_curswant] = getcurpos()
  call assert_equal(3, l:lnum, 'Cursor should not move')
endfunction

function! Test_mkdir_tab_completes_child_directories()
  call s:set_up_project(['somedir/', 'otherdir/'])
  edit .
  call feedkeys("dsom\<C-L>newdir\<Esc>", 'tx')
  call assert_match('somedir/newdir$', histget('cmd', -1))
endfunction

function! Test_shift_d_key_prompts_deletion_of_file_under_cursor()
  call s:set_up_project(['file_a', 'file_b', 'file_c'])
  let l:terminal = strager#subvim#launch_vim_in_terminal()
  call strager#subvim#run_ex_command(
    \ l:terminal,
    \ printf('edit %s', fnameescape(getcwd())),
  \ )
  call strager#subvim#run_ex_command(l:terminal, '3')

  call term_sendkeys(l:terminal, 'D')
  call term_wait(l:terminal)
  call assert_equal(
    \ 'Delete file_c? [yN] ',
    \ s:scrape_command_line_row_text_from_vim_terminal(l:terminal),
  \ )
endfunction

function! Test_shift_d_key_then_yes_deletes_file_under_cursor()
  call s:set_up_project(['file_a', 'file_b', 'file_c'])
  let l:project_path = getcwd()
  edit .
  3
  execute "normal Dy\<CR>"
  call assert_equal(
    \ ['.', '..', 'file_a', 'file_b'],
    \ sort(strager#file#list_directory(l:project_path)),
  \ )
endfunction

function! Test_shift_d_key_then_no_does_not_delete_file_under_cursor()
  call s:set_up_project(['file'])
  let l:project_path = getcwd()
  edit .
  execute "normal Dn\<CR>"
  call assert_equal(
    \ ['.', '..', 'file'],
    \ sort(strager#file#list_directory(l:project_path)),
  \ )
endfunction

function! Test_shift_d_key_then_enter_does_not_delete_file_under_cursor()
  call s:set_up_project(['file'])
  let l:project_path = getcwd()
  edit .
  execute "normal D\<CR>"
  call assert_equal(
    \ ['.', '..', 'file'],
    \ sort(strager#file#list_directory(l:project_path)),
  \ )
endfunction

function! Test_deleting_file_with_shift_d_updates_browser()
  call s:set_up_project(['file_a', 'file_b', 'file_c'])
  edit .
  2
  execute "normal Dy\<CR>"
  call assert_equal(
    \ ['file_a', 'file_c'],
    \ strager#buffer#get_current_buffer_lines(),
  \ )
endfunction

function! Test_writing_new_file_updates_browser_in_split()
  call s:set_up_project([])
  edit .
  let l:browser_buffer_number = bufnr('%')

  split new_file.txt
  write
  call assert_equal(
    \ ['new_file.txt'],
    \ strager#buffer#get_buffer_lines(l:browser_buffer_number),
  \ )
endfunction

function! Test_writing_new_file_does_not_change_focus_to_browser_in_split()
  call s:set_up_project([])
  edit .

  split new_file.txt
  let l:file_buffer_number = bufnr('%')
  write
  call assert_equal(l:file_buffer_number, bufnr('%'))
endfunction

function! s:set_up_project(files_to_create)
  let l:project_path = strager#file#make_directory_with_files(a:files_to_create)
  execute 'cd '.fnameescape(l:project_path)
  %bwipeout!
endfunction

function! s:get_relative_path_of_current_buffer()
  return fnamemodify(bufname('%'), ':.')
endfunction

function s:scrape_command_line_row_text_from_vim_terminal(terminal)
  let l:cells = s:scrape_command_line_row_from_vim_terminal(a:terminal)
  call map(l:cells, {_, cell -> cell.chars})
  return join(l:cells, '')
endfunction

function s:scrape_command_line_row_from_vim_terminal(terminal)
  let [l:row_count, l:_column_count] = term_getsize(a:terminal)
  return term_scrape(a:terminal, l:row_count)
endfunction

call strager#test#run_all_tests()
