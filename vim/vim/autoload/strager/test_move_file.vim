" TODO(strager):
"
" * Preserve filesystem state:
"   * File owner
"   * Inode number (if on same device)
"
" * Preserve Vim state:
"   * Alternate file name
"   * Cursor with unsaved changes
"   * Location lists
"   * Marks
"   * Signs
"   * Undo stack
"   * Window scroll position
"
" * Modify Vim state:
"   * Argument list (:args)
"
" * Features:
"   * :set shortmess+=F should hide file message
"   * :silent should hide file message
"   * Move directories, not just regular files
"   * Override destination with [!] or 'writeany
"
" * Other design choices:
"   * Should 'filetype change or be preserved?
"   * Should moving :cd if 'autochdir is set?
"   * Should moving fail if either 'readonly or 'nomodifiable are set?
"
" * Edge cases:
"   * :Move with % and other special characters in path
"   * :Move with spaces in path
"   * Buffer notedited flag before or after move
"   * Deleting source file fails (e.g. directory is read-only)
"   * Destination changed outside Vim after move (:help timestamp)
"   * Destination deleted then recreated outside Vim after move
"   * Destination directory is not writable
"   * Destination exists but with a different case
"   * Destination exists but with different directory case
"   * Destination is source with different case
"   * Marks, settings, etc. if we re-open the old file
"   * Move command-line window (q:)
"   * Open destination, close destination, then move something to destination
"   * Open destination, hide destination, then move something to destination
"   * Source changed outside Vim before move (:help timestamp)
"   * Swap file exists for destination
"   * Weird destination file names like % and *
"   * Weird source file names like % and *

function Test_move_command_without_argument_fails() abort
  call strager#move_file#register_command({'force': v:true})
  call s:set_up_test_project()
  edit old.txt
  call assert_fails('Move', 'E471:')
endfunction

function Test_move_command_completes_relative_directory_names() abort
  call strager#move_file#register_command({'force': v:true})
  call s:set_up_test_project()
  edit old.txt
  call feedkeys(":Move d\<C-L>\<Esc>", 'tx')
  call assert_equal('Move dir/', histget('cmd', -1))
endfunction

function Test_move_command_completes_relative_file_names() abort
  call strager#move_file#register_command({'force': v:true})
  call s:set_up_test_project()
  edit old.txt
  call feedkeys(":Move READM\<C-L>\<Esc>", 'tx')
  call assert_equal('Move README.md', histget('cmd', -1))
endfunction

function Test_move_command_expands_current_path_with_c_r_percent() abort
  call strager#move_file#register_command({'force': v:true})
  call s:set_up_test_project()
  edit old.txt
  call feedkeys(":Move \<C-R>%\<Esc>", 'tx')
  call assert_equal('Move old.txt', histget('cmd', -1))
endfunction

function Test_move_command_expands_env_vars() abort
  call strager#move_file#register_command({'force': v:true})
  call s:set_up_test_project()
  edit old.txt
  let l:dir_path = getcwd()
  let $TESTPATH = l:dir_path
  call feedkeys(":Move $TESTPATH/\<C-L>\<Esc>", 'tx')
  call assert_equal(
    \ printf('Move %s/', fnameescape(l:dir_path)),
    \ histget('cmd', -1),
  \ )
endfunction

function Test_move_command_changes_current_buffer() abort
  call strager#move_file#register_command({'force': v:true})
  call s:set_up_test_project()
  edit old.txt
  Move new.txt
  call assert_equal('new.txt', bufname('%'))
endfunction

function Test_move_absolute_creates_new_file() abort
  call s:set_up_test_project()
  edit old.txt
  call s:move_current_buffer_file(s:absolute_path('new.txt'))
  call s:assert_file_exists('new.txt')
  call assert_equal(['Hello, world!', ''], readfile('new.txt', 'b'))
endfunction

function Test_move_absolute_deletes_old_file() abort
  call s:set_up_test_project()
  edit old.txt
  call s:move_current_buffer_file(s:absolute_path('new.txt'))
  call s:assert_file_does_not_exist('old.txt')
endfunction

function Test_move_absolute_changes_current_buffer() abort
  call s:set_up_test_project()
  edit old.txt
  call s:move_current_buffer_file(s:absolute_path('new.txt'))
  call assert_equal(s:absolute_path('new.txt'), bufname('%'))
endfunction

function Test_move_relative_creates_new_file() abort
  call s:set_up_test_project()
  edit old.txt
  call s:move_current_buffer_file('new.txt')
  call s:assert_file_exists('new.txt')
  call assert_equal(['Hello, world!', ''], readfile('new.txt', 'b'))
endfunction

function Test_move_relative_deletes_old_file() abort
  call s:set_up_test_project()
  edit old.txt
  call s:move_current_buffer_file('new.txt')
  call s:assert_file_does_not_exist('old.txt')
endfunction

function Test_move_relative_changes_current_buffer() abort
  call s:set_up_test_project()
  edit old.txt
  call s:move_current_buffer_file('new.txt')
  call assert_equal('new.txt', bufname('%'))
endfunction

function Test_move_unloads_old_file() abort
  call s:set_up_test_project()
  edit old.txt
  call s:move_current_buffer_file('new.txt')
  call assert_equal(-1, bufnr('old.txt'))
endfunction

function Test_move_then_move_back_restores_files() abort
  call s:set_up_test_project()
  edit old.txt
  call s:move_current_buffer_file('new.txt')
  call s:move_current_buffer_file('old.txt')
endfunction

function Test_move_to_empty_string_fails() abort
  call s:set_up_test_project()
  edit old.txt
  call strager#assert#assert_throws(
    \ {-> s:move_current_buffer_file('')}, 
    \ 'E484:',
    \ "Moving should fail with error: E484: Can't open file <empty>",
  \ )
endfunction

function Test_move_to_missing_directory_fails() abort
  call s:set_up_test_project()
  edit old.txt
  call strager#assert#assert_throws(
    \ {-> s:move_current_buffer_file('newdir/old.txt')}, 
    \ 'ES001: Directory does not exist (newdir)',
  \ )
  call s:assert_file_exists('old.txt')
  call assert_equal('old.txt', bufname('%'))
endfunction

function Test_move_to_unwritable_directory_fails() abort
  call s:set_up_test_project()
  edit old.txt
  call strager#assert#assert_throws(
    \ {-> s:move_current_buffer_file('readonlydir/new.txt')}, 
    \ 'E212:',
    \ "Moving should fail with error: E212: Can't open file for writing",
  \ )
  call s:assert_file_exists('old.txt')
  call s:assert_file_does_not_exist('readonlydir/new.txt')
endfunction

function Test_move_to_unwritable_directory_keeps_unsaved_changes_unsaved() abort
  call s:set_up_test_project()
  edit old.txt
  silent! normal oGreetings.

  try
    call s:move_current_buffer_file('readonlydir/new.txt')
    call assert_fail('Moving should throw')
  catch
    " Keep going.
  endtry
  call assert_true(
    \ getbufvar('%', '&modified'),
    \ 'Buffer should still be marked as modified'
  \ )
  call assert_equal(
    \ ['Hello, world!', 'Greetings.'],
    \ strager#buffer#get_current_buffer_lines(),
  \ )
endfunction

function Test_move_over_existing_fails() abort
  call s:set_up_test_project()
  edit old.txt
  call strager#assert#assert_throws(
    \ {-> s:move_current_buffer_file('README.md')}, 
    \ 'E13:',
    \ 'Moving should fail with error: E13: File exists',
  \ )
  call s:assert_file_exists('old.txt')
endfunction

function Test_move_new_over_existing_fails() abort
  call s:set_up_test_project()
  edit doesnotexist.txt
  call strager#assert#assert_throws(
    \ {-> s:move_current_buffer_file('README.md')}, 
    \ 'E13:',
    \ 'Moving should fail with error: E13: File exists',
  \ )
  call s:assert_file_exists('README.md')
  call s:assert_file_does_not_exist('doesnotexist.txt')
endfunction

function Test_move_relative_over_self_relative_does_not_delete_file() abort
  call s:set_up_test_project()
  edit old.txt
  call s:move_current_buffer_file('old.txt')
  call s:assert_file_exists('old.txt')
endfunction

function Test_move_relative_over_self_absolute_does_not_delete_file() abort
  call s:set_up_test_project()
  edit old.txt
  call s:move_current_buffer_file(s:absolute_path('old.txt'))
  call s:assert_file_exists('old.txt')
endfunction

function Test_move_absolute_over_self_absolute_does_not_delete_file() abort
  call s:set_up_test_project()
  exec 'edit '.fnameescape('old.txt')
  call s:move_current_buffer_file(s:absolute_path('old.txt'))
  call s:assert_file_exists('old.txt')
endfunction

function Test_move_absolute_over_self_relative_does_not_delete_file() abort
  call s:set_up_test_project()
  exec 'edit '.fnameescape('old.txt')
  call s:move_current_buffer_file('old.txt')
  call s:assert_file_exists('old.txt')
endfunction

function Test_move_missing_file_fails() abort
  call s:set_up_test_project()
  edit old.txt
  call delete('old.txt')

  call strager#assert#assert_throws(
    \ {-> s:move_current_buffer_file('new.txt')}, 
    \ 'E484:',
    \ "Moving should fail with error: E484: Can't open file",
  \ )
  call s:assert_file_does_not_exist('old.txt')
  call s:assert_file_does_not_exist('new.txt')
endfunction

function Test_move_over_symlink_to_self_fails() abort
  call s:set_up_test_project()
  edit old.txt

  call strager#assert#assert_throws(
    \ {-> s:move_current_buffer_file('oldsymlink.txt')}, 
    \ 'E13:',
    \ 'Moving should fail with error: E13: File exists',
  \ )
  call s:assert_file_exists('old.txt')
  call s:assert_file_exists('oldsymlink.txt')
endfunction

function Test_move_symlink_over_self_does_not_delete() abort
  call s:set_up_test_project()
  edit oldsymlink.txt
  call s:move_current_buffer_file('oldsymlink.txt')
  call s:assert_file_exists('old.txt')
  call s:assert_file_exists('oldsymlink.txt')
endfunction

function Test_move_symlink_over_target_fails() abort
  call s:set_up_test_project()
  edit oldsymlink.txt

  call strager#assert#assert_throws(
    \ {-> s:move_current_buffer_file('old.txt')}, 
    \ 'E13:',
    \ 'Moving should fail with error: E13: File exists',
  \ )
  call s:assert_file_exists('old.txt')
  call s:assert_file_exists('oldsymlink.txt')
endfunction

function Test_move_new_file_does_not_write() abort
  call s:set_up_test_project()
  edit from.txt
  silent! normal itext goes here

  call s:move_current_buffer_file('to.txt')
  call s:assert_file_does_not_exist('from.txt')
  call s:assert_file_does_not_exist('to.txt')
endfunction

function Test_move_new_file_changes_current_buffer() abort
  call s:set_up_test_project()
  edit from.txt
  silent! normal itext goes here

  call s:move_current_buffer_file('to.txt')
  call assert_equal('to.txt', bufname('%'))
endfunction

function Test_move_new_file_then_write_saves_changes() abort
  call s:set_up_test_project()
  edit from.txt
  silent! normal itext goes here

  call s:move_current_buffer_file('to.txt')
  write
  call assert_equal(
    \ ['text goes here', ''],
    \ readfile('to.txt', 'b'),
  \ )
endfunction

function Test_move_to_opened_new_file_fails() abort
  call s:set_up_test_project()
  edit new.txt
  split old.txt

  call strager#assert#assert_throws(
    \ {-> s:move_current_buffer_file('new.txt')}, 
    \ 'E139:',
    \ 'Moving should fail with error: E139: File is loaded in another buffer',
  \ )
  call s:assert_file_exists('old.txt')
  call s:assert_file_does_not_exist('new.txt')
endfunction

function Test_move_to_opened_file_fails() abort
  call s:set_up_test_project()
  edit new.txt
  write
  split old.txt

  call strager#assert#assert_throws(
    \ {-> s:move_current_buffer_file('new.txt')}, 
    \ 'E139:',
    \ 'Moving should fail with error: E139: File is loaded in another buffer',
  \ )
  call s:assert_file_exists('old.txt')
  call s:assert_file_exists('new.txt')
endfunction

function Test_move_to_opened_symlink_fails() abort
  call s:set_up_test_project()
  edit oldsymlink.txt
  write
  split README.md

  call strager#assert#assert_throws(
    \ {-> s:move_current_buffer_file('oldsymlink.txt')}, 
    \ 'E139:',
    \ 'Moving should fail with error: E139: File is loaded in another buffer',
  \ )
  call s:assert_file_exists('oldsymlink.txt')
  call s:assert_file_exists('old.txt')
  call s:assert_file_exists('README.md')
endfunction

function Test_move_to_symlink_of_opened_file_fails() abort
  call s:set_up_test_project()
  edit old.txt
  write
  split README.md

  call strager#assert#assert_throws(
    \ {-> s:move_current_buffer_file('oldsymlink.txt')}, 
    \ 'E139:',
    \ 'Moving should fail with error: E139: File is loaded in another buffer',
  \ )
  call s:assert_file_exists('oldsymlink.txt')
  call s:assert_file_exists('old.txt')
  call s:assert_file_exists('README.md')
endfunction

function Test_move_to_opened_symlink_target_fails() abort
  call s:set_up_test_project()
  edit oldsymlink.txt
  write
  split README.md

  call strager#assert#assert_throws(
    \ {-> s:move_current_buffer_file('old.txt')}, 
    \ 'E139:',
    \ 'Moving should fail with error: E139: File is loaded in another buffer',
  \ )
  call s:assert_file_exists('oldsymlink.txt')
  call s:assert_file_exists('old.txt')
  call s:assert_file_exists('README.md')
endfunction

function Test_move_to_opened_file_with_percent_name_fails() abort
  call s:set_up_test_project()
  edit \%
  write
  split old.txt

  call strager#assert#assert_throws(
    \ {-> s:move_current_buffer_file('%')}, 
    \ 'E139:',
    \ 'Moving should fail with error: E139: File is loaded in another buffer',
  \ )
  call s:assert_file_exists('old.txt')
  call s:assert_file_exists('%')
endfunction

function Test_move_to_file_with_same_name_as_nofile_buffer_file() abort
  call s:set_up_test_project()
  edit new.txt
  setlocal buftype=nofile
  split old.txt

  call strager#assert#assert_throws(
    \ {-> s:move_current_buffer_file('new.txt')}, 
    \ 'E139:',
    \ 'Moving should fail with error: E139: File is loaded in another buffer',
  \ )
  call s:assert_file_exists('old.txt')
  call s:assert_file_does_not_exist('new.txt')
endfunction

function Test_move_updates_other_windows() abort
  call s:set_up_test_project()
  edit old.txt
  exec 'vsplit '.fnameescape(s:absolute_path('old.txt'))
  vsplit old.txt
  let l:old_buffer_number = bufnr('%')
  call assert_notequal(-1, l:old_buffer_number)
  let l:old_window_ids = win_findbuf(l:old_buffer_number)
  call assert_equal(3, len(l:old_window_ids))

  call s:move_current_buffer_file('new.txt')

  let l:new_buffer_number = bufnr('%')
  call assert_notequal(-1, l:new_buffer_number)
  let l:new_window_ids = win_findbuf(l:new_buffer_number)
  call assert_equal(3, len(l:new_window_ids))
endfunction

function Test_move_keeps_unsaved_changes_unsaved() abort
  call s:set_up_test_project()
  edit old.txt
  silent! normal oGreetings.

  call s:move_current_buffer_file('new.txt')
  call assert_true(
    \ getbufvar('%', '&modified'),
    \ 'Buffer should still be marked as modified'
  \ )
  call assert_equal(['Hello, world!', ''], readfile('new.txt', 'b'))
endfunction

function Test_move_with_unsaved_changes_then_write_saves_changes() abort
  call s:set_up_test_project()
  edit old.txt
  silent! normal oGreetings.

  call s:move_current_buffer_file('new.txt')
  write
  call assert_equal(
    \ ['Hello, world!', 'Greetings.', ''],
    \ readfile('new.txt', 'b'),
  \ )
endfunction

function Test_move_with_saved_changes_keeps_changes() abort
  call s:set_up_test_project()
  edit old.txt
  silent! normal oGreetings.
  write

  call s:move_current_buffer_file('new.txt')
  call assert_false(
    \ getbufvar('%', '&modified'),
    \ 'Buffer should still be marked as unmodified'
  \ )
  call assert_equal(
    \ ['Hello, world!', 'Greetings.'],
    \ strager#buffer#get_current_buffer_lines(),
  \ )
  call assert_equal(
    \ ['Hello, world!', 'Greetings.', ''],
    \ readfile('new.txt', 'b'),
  \ )
endfunction

function Test_move_preserves_cursor_location() abort
  call s:set_up_test_project()
  edit old.txt

  " Move the cursor to the 'w' in 'world'.
  silent! normal W
  let [l:_bufnum, l:old_lnum, l:old_col, l:_off, l:_curswant] = getcurpos()
  call assert_equal(
    \ {'column': 8, 'line': 1},
    \ {'column': l:old_col, 'line': l:old_lnum},
  \ )

  call s:move_current_buffer_file('new.txt')

  let [l:_bufnum, l:new_lnum, l:new_col, l:_off, l:_curswant] = getcurpos()
  call assert_equal(
    \ {'column': l:old_col, 'line': l:old_lnum},
    \ {'column': l:new_col, 'line': l:new_lnum},
  \ )
endfunction

function Test_move_preserves_file_permissions() abort
  for l:permissions in ['rw-------', 'rw-r--r--', 'rw-rw-rw-', 'rwxr-xr-x']
    call s:set_up_test_project()
    let l:ok = setfperm('old.txt', l:permissions)
    if l:ok == 0
      throw 'Failed to change file permissions'
    endif
    call assert_equal(l:permissions, getfperm('old.txt'))

    edit old.txt
    call s:move_current_buffer_file('new.txt')
    call assert_equal(l:permissions, getfperm('new.txt'))
  endfor
endfunction

function Test_move_directory_fails() abort
  call s:set_up_test_project()
  edit emptydir

  call strager#assert#assert_throws(
    \ {-> s:move_current_buffer_file('newdir')}, 
    \ 'E502:',
    \ 'Moving should fail with error: E502: Current buffer is a directory',
  \ )
  call s:assert_file_does_not_exist('newdir')
  call s:assert_file_exists('emptydir')
endfunction

function Test_move_to_directory_fails() abort
  call s:set_up_test_project()
  edit old.txt

  call strager#assert#assert_throws(
    \ {-> s:move_current_buffer_file('emptydir')}, 
    \ 'E17:',
    \ 'Moving should fail with error: E17: File is a directory',
  \ )
  call s:assert_file_exists('old.txt')
  call s:assert_directory_exists('emptydir')
endfunction

function Test_move_in_unnamed_buffer_fails() abort
  call s:set_up_test_project()
  new

  call strager#assert#assert_throws(
    \ {-> s:move_current_buffer_file('new.txt')}, 
    \ 'E32:',
    \ 'Moving should fail with error: E32: No file name',
  \ )
endfunction

function Test_move_in_quickfix_buffer_fails() abort
  call s:set_up_test_project()
  edit old.txt
  copen

  call strager#assert#assert_throws(
    \ {-> s:move_current_buffer_file('new.txt')}, 
    \ 'E32:',
    \ 'Moving should fail with error: E32: No file name',
  \ )
endfunction

function Test_move_in_terminal_buffer_fails() abort
  call s:set_up_test_project()
  edit old.txt
  terminal

  call strager#assert#assert_throws(
    \ {-> s:move_current_buffer_file('new.txt')}, 
    \ 'E32:',
    \ 'Moving should fail with error: E32: No file name',
  \ )
endfunction

function Test_move_to_file_with_star_with_related_buffers_open() abort
  " Make sure the new path isn't treated as a wild card matching open buffers.
  call s:set_up_test_project()
  edit README.md
  split old.txt
  call s:move_current_buffer_file('READ*.md')
  call s:assert_file_does_not_exist('old.txt')
  call s:assert_file_exists('READ*.md')
  call s:assert_file_exists('README.md')
endfunction

function Test_move_to_file_with_base_name_open() abort
  " Make sure the new path isn't treated as a substring matching open buffers.
  call s:set_up_test_project()
  edit dir/new_file
  split old.txt
  call s:move_current_buffer_file('new_file')
  call s:assert_file_does_not_exist('old.txt')
  call s:assert_file_exists('new_file')
  call s:assert_file_exists('dir/new_file')
endfunction

function Test_move_to_prefix_of_open_file() abort
  " Make sure the new path isn't treated as a substring matching open buffers.
  call s:set_up_test_project()
  edit README.md
  split old.txt
  call s:move_current_buffer_file('README')
  call s:assert_file_does_not_exist('old.txt')
  call s:assert_file_exists('README')
  call s:assert_file_exists('README.md')
endfunction

function Test_move_to_file_containing_nomagic_pattern() abort
  " Make sure the new path isn't treated as a nomagic pattern matching open
  " buffers.
  call s:set_up_test_project()
  edit README.md
  split old.txt
  call s:move_current_buffer_file('REA\.ME.md')
  call s:assert_file_does_not_exist('old.txt')
  call s:assert_file_exists('README.md')
  call s:assert_file_exists('REA\.ME.md')
endfunction

function Test_move_to_backslash_with_dollar_file_open() abort
  call s:set_up_test_project()
  edit $
  split old.txt
  call s:move_current_buffer_file('\')
  call s:assert_file_does_not_exist('old.txt')
  call s:assert_file_does_not_exist('$')
  call s:assert_file_exists('\')
endfunction

function Test_move_updates_quickfix_list() abort
  call s:set_up_test_project()
  edit README.md

  silent vimgrep /\Creadme/ %
  call s:assert_cursor_on_line(3)

  call s:move_current_buffer_file('new.txt')
  cnext
  call s:assert_cursor_on_line(5)
endfunction

function Test_move_shows_new_file_info_in_status_line() abort
  call s:set_up_test_project()
  edit old.txt
  set ruler

  let l:messages_before = strager#messages#get_messages()
  call s:move_current_buffer_file('new.txt')
  let l:messages_after = strager#messages#get_messages()
  call assert_equal(
    \ ['"new.txt" 1 line --100%--'],
    \ strager#messages#get_new_messages(l:messages_before),
  \ )
endfunction

function Test_move_shows_new_file_info_in_status_line_noruler() abort
  call s:set_up_test_project()
  edit old.txt
  set noruler

  let l:messages_before = strager#messages#get_messages()
  call s:move_current_buffer_file('new.txt')
  let l:messages_after = strager#messages#get_messages()
  call assert_equal(
    \ ['"new.txt" line 1 of 1 --100%-- col 1'],
    \ strager#messages#get_new_messages(l:messages_before),
  \ )
endfunction

function Test_move_with_unsaved_changes_shows_new_file_info_in_status_line_noruler() abort
  let l:shortmess_to_message = {
    \ '': '"new.txt" [Modified] line 1 of 2 --50%-- col 1',
    \ 'filnxtToO': '"new.txt" [Modified] line 1 of 2 --50%-- col 1',
    \ 'atToO': '"new.txt" [+] line 1 of 2 --50%-- col 1',
  \ }
  for [l:shortmess, l:expected_message] in items(l:shortmess_to_message)
    call s:set_up_test_project()
    edit old.txt
    silent! normal oGreetings.
    1
    set noruler
    let &shortmess = l:shortmess

    let l:messages_before = strager#messages#get_messages()
    call s:move_current_buffer_file('new.txt')
    let l:messages_after = strager#messages#get_messages()
    call assert_equal(
      \ [l:expected_message],
      \ strager#messages#get_new_messages(l:messages_before),
    \ )
  endfor
endfunction

function s:assert_cursor_on_line(expected_line_number) abort
  let [l:_bufnum, l:lnum, l:_col, l:_off, l:_curswant] = getcurpos()
  call assert_equal(a:expected_line_number, l:lnum)
endfunction

function s:move_current_buffer_file(new_path) abort
  call strager#move_file#move_current_buffer_file(a:new_path)
endfunction

function s:set_up_test_project() abort
  call s:clean_up()
  let l:test_project_path = strager#file#make_directory_with_files([
    \ ['README.md', "===== README =====\n\nWelcome to the readme.\n\nThis readme is comprehensive.\n"],
    \ 'dir/new_file',
    \ 'emptydir/',
    \ ['old.txt', "Hello, world!\n"],
    \ 'readonlydir/',
  \ ])
  exec 'cd '.fnameescape(l:test_project_path)
  call setfperm('readonlydir', 'r-xr-xr-x')
  call strager#file#create_symbolic_link('old.txt', 'oldsymlink.txt')
endfunction

function s:clean_up() abort
  %bwipeout!
endfunction

function s:assert_file_exists(path) abort
  call assert_true(
    \ strager#file#file_exists_case_sensitive(a:path),
    \ printf('File should exist at %s', a:path),
  \ )
endfunction

function s:assert_directory_exists(path) abort
  call s:assert_file_exists(a:path)
  call assert_equal(
    \ 'dir',
    \ getftype(a:path),
    \ printf('File should be a directory: %s', a:path)
  \ )
endfunction

function s:assert_file_does_not_exist(path) abort
  call assert_false(
    \ strager#file#file_exists_case_sensitive(a:path),
    \ printf('File should not exist at %s', a:path),
  \ )
endfunction

function s:absolute_path(relative_path) abort
  return strager#path#join([getcwd(), a:relative_path])
endfunction

call strager#test#run_all_tests()
