function! Test_grep_with_no_files_clears_quickfix_list()
  call s:set_up_project([])
  silent grep hello
  let l:quickfix_items = getqflist({'all': v:true}).items
  call assert_equal([], l:quickfix_items)
endfunction

function! Test_grep_finds_single_match()
  call s:set_up_project([
    \ ['readme.txt', 'hello there!'],
    \ ['other.txt', 'no match here.'],
  \ ])
  silent grep hello
  let l:quickfix_items = getqflist({'all': v:true}).items
  call assert_equal(1, len(l:quickfix_items))
  call assert_equal(bufnr('readme.txt'), l:quickfix_items[0].bufnr)
endfunction

function! Test_grep_matches_with_location()
  call s:set_up_project([
    \ ['readme.txt', "first line\nsecond line\nthird line\nand the final line\n"],
  \ ])

  silent grep third
  let l:quickfix_items = getqflist({'all': v:true}).items
  call assert_equal(1, len(l:quickfix_items))
  call assert_equal(bufnr('readme.txt'), l:quickfix_items[0].bufnr)
  call assert_equal(3, l:quickfix_items[0].lnum)
  call assert_equal(1, l:quickfix_items[0].col)

  silent grep final
  let l:quickfix_items = getqflist({'all': v:true}).items
  call assert_equal(1, len(l:quickfix_items))
  call assert_equal(bufnr('readme.txt'), l:quickfix_items[0].bufnr)
  call assert_equal(4, l:quickfix_items[0].lnum)
  call assert_equal(len('and the ') + 1, l:quickfix_items[0].col)
endfunction

function! Test_grep_matches_multiple_files()
  call s:set_up_project([
    \ ['dates.txt', "january third\njanuary thirty?\n"],
    \ ['readme.txt', "first line\nsecond line\nthird line\nfourth line\n"],
  \ ])
  silent grep third
  let l:readme_quickfix_items = s:get_quickfix_items_for_buffer_name('readme.txt')
  call assert_equal(1, len(l:readme_quickfix_items))
  let l:dates_quickfix_items = s:get_quickfix_items_for_buffer_name('dates.txt')
  call assert_equal(1, len(l:dates_quickfix_items))
endfunction

function! Test_grep_with_explicit_directory_finds_single_match_in_subdirectory()
  call s:set_up_project([
    \ ['readme.txt', 'hello there!'],
    \ ['searcheddir/readme.txt', 'why, hello!'],
  \ ])
  silent grep hello searcheddir
  let l:quickfix_items = getqflist({'all': v:true}).items
  call assert_equal(1, len(l:quickfix_items))
  call assert_equal(bufnr('searcheddir/readme.txt'), l:quickfix_items[0].bufnr)
endfunction

function! s:set_up_project(files_to_create)
  let l:project_path = strager#file#make_directory_with_files(a:files_to_create)
  exec 'cd '.fnameescape(l:project_path)
  %bwipeout!
endfunction

function! s:get_quickfix_items_for_buffer_name(buffer_name)
  let l:buffer_number = bufnr(a:buffer_name)
  let l:quickfix_items = getqflist({'all': v:true}).items
  call filter(l:quickfix_items, {_, item -> item.bufnr == l:buffer_number})
  return l:quickfix_items
endfunction

call strager#test#run_all_tests()
