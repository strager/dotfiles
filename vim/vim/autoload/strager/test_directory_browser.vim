function! Test_refreshing_open_browser_does_not_affect_undo_tree_of_current_buffer() abort
  call s:set_up()
  let l:test_directory = strager#file#make_directory_with_files([
    \ 'dir_a/hello.txt',
    \ 'file_b.txt',
  \ ])
  execute printf('cd %s', fnameescape(l:test_directory))
  edit dir_a
  split file_b.txt
  normal! ihello
  normal! oworld
  " HACK(strager): Forced undotree().synced to true.
  let &undolevels = &undolevels
  let l:original_undo_tree = undotree()

  call strager#directory_browser#refresh_open_browsers()
  call assert_equal(l:original_undo_tree, undotree())
endfunction

function! Test_refreshing_open_browser_does_not_change_layout() abort
  call s:set_up()
  let l:test_directory = strager#file#make_directory_with_files([
    \ 'dir_a/file_a.txt',
    \ 'dir_b/file_b.txt',
    \ 'dir_c/file_c.txt',
  \ ])
  execute printf('cd %s', fnameescape(l:test_directory))
  edit dir_a
  split dir_b
  tabedit dir_c
  let l:old_layout = strager#layout#get_layout_of_windows_and_tabs()

  call strager#directory_browser#refresh_open_browsers()
  call assert_equal(
    \ l:old_layout,
    \ strager#layout#get_layout_of_windows_and_tabs(),
    \ 'Layout should be the same after opening help',
  \ )
endfunction

" TODO(strager): Fix and re-enable.
function! TODO_Test_refreshing_hidden_browser_updates_content_when_unhidden() abort
  call s:set_up()
  set hidden
  let l:test_directory = strager#file#make_directory_with_files([
    \ 'subdirectory/file_a.txt',
  \ ])
  execute printf('cd %s', fnameescape(l:test_directory))
  edit subdirectory
  let l:subdirectory_buffer_number = bufnr('%')
  edit subdirectory/file_a.txt

  call writefile([], 'subdirectory/file_b.txt')
  call strager#directory_browser#refresh_open_browsers()

  execute printf('buffer %d', l:subdirectory_buffer_number)
  call assert_notequal(
    \ 0,
    \ search('file_b.txt', 'cnw'),
    \ 'The new file should be listed in the directory browser',
  \ )
endfunction

function! s:set_up() abort
  set nohidden
  %bwipeout!
endfunction

call strager#test#run_all_tests()
