" TODO(strager): Closing help window with :q or :close should not close Vim.

function! Test_help_replaces_open_current_help_window() abort
  %bwipeout!
  help :function
  only
  let l:old_layout = strager#layout#get_layout_of_windows_and_tabs()
  call assert_equal('eval.txt', s:get_current_buffer_help_file_name())

  call strager#help#open_help_tag(':set')

  call assert_equal(
    \ l:old_layout,
    \ strager#layout#get_layout_of_windows_and_tabs(),
    \ 'Layout should be the same after opening help',
  \ )
  call assert_equal('options.txt', s:get_current_buffer_help_file_name())
endfunction

function! Test_help_jumps_to_tag() abort
  %bwipeout!
  help :function
  let [l:_bufnum, l:expected_line, l:expected_column, l:expected_offset, l:_curswant] = getcurpos()
  let l:expected_buffer_name = bufname('%')
  1

  new
  only

  call strager#help#open_help_tag(':function')
  let [l:_bufnum, l:actual_line, l:actual_column, l:actual_offset, l:_curswant] = getcurpos()
  let l:actual_buffer_name = bufname('%')

  call assert_equal(
    \ printf(
      \ '%s:%d:%d(%d)',
      \ l:expected_buffer_name,
      \ l:expected_line,
      \ l:expected_column,
      \ l:expected_offset,
    \ ),
    \ printf(
      \ '%s:%d:%d(%d)',
      \ l:actual_buffer_name,
      \ l:actual_line,
      \ l:actual_column,
      \ l:actual_offset
    \ ),
  \ )
endfunction

function! Test_help_replaces_unmodified_buffer() abort
  %bwipeout!
  edit test_file.txt
  let l:old_layout = strager#layout#get_layout_of_windows_and_tabs()

  call strager#help#open_help_tag(':set')

  call assert_equal(
    \ l:old_layout,
    \ strager#layout#get_layout_of_windows_and_tabs(),
    \ 'Layout should be the same after opening help',
  \ )
  call assert_equal('options.txt', s:get_current_buffer_help_file_name())
endfunction

function! Test_help_replaces_current_window_despite_help_in_other_window() abort
  %bwipeout!
  help :function
  only
  let l:other_help_window_id = win_getid()
  new
  let l:old_other_help_window = getwininfo(l:other_help_window_id)
  let l:old_layout = strager#layout#get_layout_of_windows_and_tabs()

  call strager#help#open_help_tag(':set')

  call assert_equal('options.txt', s:get_current_buffer_help_file_name())
  call assert_equal(
    \ l:old_layout,
    \ strager#layout#get_layout_of_windows_and_tabs(),
    \ 'Layout should be the same after opening help',
  \ )
  call assert_equal(
    \ l:old_other_help_window,
    \ getwininfo(l:other_help_window_id),
    \ 'Other help window should not change after opening help in current window',
  \ )
endfunction

function! Test_help_fails_with_open_modified_unsaveable_buffer() abort
  %bwipeout!

  normal ichanges
  set nohidden
  let l:old_layout = strager#layout#get_layout_of_windows_and_tabs()
  let l:old_buffer_number = bufnr('%')

  call strager#assert#assert_throws(
    \ {-> strager#help#open_help_tag(':set')},
    \ 'E37:',
  \ )

  call assert_equal(
    \ l:old_layout,
    \ strager#layout#get_layout_of_windows_and_tabs(),
    \ 'Layout should be the same after trying to open help',
  \ )
  call assert_equal(
    \ l:old_buffer_number,
    \ bufnr('%'),
    \ 'Current buffer should not change',
  \ )
endfunction

function Test_help_command_without_argument_fails() abort
  call strager#help#register_command({'force': v:true})
  call assert_fails('Help', 'E471:')
endfunction

function! Test_help_for_unknown_tag_fails() abort
  %bwipeout!

  let l:old_layout = strager#layout#get_layout_of_windows_and_tabs()
  let l:old_buffer_number = bufnr('%')

  call strager#assert#assert_throws(
    \ {-> strager#help#open_help_tag('this_help_tag_does_not_exist')},
    \ 'E149:',
  \ )

  call assert_equal(
    \ l:old_layout,
    \ strager#layout#get_layout_of_windows_and_tabs(),
    \ 'Layout should be the same after trying to open help',
  \ )
  call assert_equal(
    \ l:old_buffer_number,
    \ bufnr('%'),
    \ 'Current buffer should not change',
  \ )
endfunction

function Test_help_command_completes_tags() abort
  call strager#help#register_command({'force': v:true})
  call feedkeys(":Help keypad-divi\<C-L>\<Esc>", 'tx')
  call assert_equal('Help keypad-divide', histget('cmd', -1))
endfunction

function! s:get_current_buffer_help_file_name() abort
  return fnamemodify(bufname('%'), ':t')
endfunction

call strager#test#run_all_tests()
