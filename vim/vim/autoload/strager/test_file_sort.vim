function! Test_single_item_sorts_to_itself()
  call assert_equal(['hello'], s:sort(['hello']))
  call assert_equal(['hello/'], s:sort(['hello/']))
endfunction

function! Test_ordered_files_preserve_order()
  call assert_equal(['a', 'b'], s:sort(['a', 'b']))
endfunction

function! Test_ordered_directories_preserve_order()
  call assert_equal(['a/', 'b/'], s:sort(['a/', 'b/']))
endfunction

function! Test_unordered_files_are_sorted()
  call assert_equal(['a', 'b'], s:sort(['b', 'a']))
endfunction

function! Test_directories_appear_before_regular_files()
  call assert_equal(['x_dir/', 'y_file'], s:sort(['x_dir/', 'y_file']))
  call assert_equal(['y_dir/', 'x_file'], s:sort(['x_file', 'y_dir/']))
  call assert_equal(['y_dir/', 'x_file'], s:sort(['y_dir/', 'x_file']))
endfunction

function! Test_fuzz_directories_appear_before_regular_files()
  let l:rng = strager#random_mt19937#make_generator(5489)
  let l:iteration = 0
  while l:iteration < 100
    let l:regular_file_names = s:random_file_names(l:rng)
    let l:directory_names = s:random_file_names(l:rng)
    call map(l:directory_names, {_, name -> name.'/'})
    let l:names = l:regular_file_names + l:directory_names

    let l:sorted = s:sort(l:names)
    let l:context = printf('Sorted names: %s', l:sorted)
    for l:i in range(0, len(l:directory_names) - 1)
      let l:entry = l:sorted[l:i]
      call assert_equal(count(l:directory_names, l:entry), 1, printf(
        \ "Regular file should come after directories: %s\n%s",
        \ l:entry,
        \ l:context,
      \ ))
    endfor
    for l:i in range(len(l:directory_names), len(l:sorted) - 1)
      let l:entry = l:sorted[l:i]
      call assert_equal(count(l:regular_file_names, l:entry), 1, printf(
        \ "Directory should come before regular files: %s\n%s",
        \ l:entry,
        \ l:context,
      \ ))
    endfor

    if v:errors !=# []
      break
    endif

    let l:iteration += 1
  endwhile
endfunction

let s:some_legal_file_name_characters = split('abcdefABCDEF.-()', '\zs')

function! s:random_file_names(rng)
  let l:length = strager#random_mt19937#next_integer(a:rng, 1, 5)
  let l:names = []
  while len(l:names) < l:length
    let l:name = s:random_file_name(a:rng)
    if count(l:names, l:name) == 0
      call add(l:names, l:name)
    endif
  endwhile
  return l:names
endfunction

function! s:random_file_name(rng)
  let l:length = strager#random_mt19937#next_integer(a:rng, 1, 7)
  let l:name = ''
  while l:name ==# '' || l:name ==# '.' || l:name ==# '..'
    let l:chars = map(
      \ range(l:length),
      \ {-> strager#random_mt19937#next_item_in_list(
        \ a:rng,
        \ s:some_legal_file_name_characters,
      \ )}
    \ )
    let l:name = join(l:chars, '')
  endwhile
  return l:name
endfunction

function! Test_dot_files_appear_before_regular_files()
  call assert_equal(['.x_file', 'y_file'], s:sort(['.x_file', 'y_file']))
  call assert_equal(['.y_file', 'x_file'], s:sort(['x_file', '.y_file']))
  call assert_equal(['.y_file', 'x_file'], s:sort(['.y_file', 'x_file']))
endfunction

function! s:sort(lines)
  call strager#buffer#set_current_buffer_lines(a:lines)
  call strager#file_sort#sort_current_buffer()
  return strager#buffer#get_current_buffer_lines()
endfunction

call strager#test#run_all_tests()
