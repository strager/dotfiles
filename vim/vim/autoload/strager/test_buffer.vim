function Test_new_unnamed_buffer_is_new() abort
  new
  call assert_true(strager#buffer#is_current_buffer_new())
endfunction

function Test_new_named_buffer_is_new() abort
  let l:dir_path = strager#file#make_directory_with_files([])
  new
  exec 'file '.fnameescape(strager#path#join([l:dir_path, 'missingfile.txt']))
  call assert_true(strager#buffer#is_current_buffer_new())
endfunction

function Test_new_file_buffer_is_new() abort
  let l:dir_path = strager#file#make_directory_with_files([])
  exec 'edit '.fnameescape(strager#path#join([l:dir_path, 'missingfile.txt']))
  call assert_true(strager#buffer#is_current_buffer_new())
endfunction

function Test_existing_file_is_not_new() abort
  let l:dir_path = strager#file#make_directory_with_files(['file.txt'])
  exec 'edit '.fnameescape(strager#path#join([l:dir_path, 'file.txt']))
  call assert_false(strager#buffer#is_current_buffer_new())
endfunction

function Test_checking_buffer_newness_does_not_add_message() abort
  let l:dir_path = strager#file#make_directory_with_files(['file.txt'])
  exec 'edit '.fnameescape(strager#path#join([l:dir_path, 'file.txt']))

  let l:messages_before = strager#messages#get_messages()
  call strager#buffer#is_current_buffer_new()
  call assert_equal([], strager#messages#get_new_messages(l:messages_before))
endfunction

function Test_no_buffer_number_for_nonexistant_name() abort
  %bwipeout!
  call assert_equal(-1, strager#buffer#buffer_number_by_name('somebuffer'))
endfunction

function Test_absolute_buffer_number_by_absolute_file_path() abort
  %bwipeout!
  let l:dir_path = strager#file#make_directory_with_files(['file.txt'])
  let l:file_path = strager#path#join([l:dir_path, 'file.txt'])
  exec 'edit '.fnameescape(l:file_path)
  let l:buffer_number = bufnr('%')
  call assert_equal(
    \ l:buffer_number,
    \ strager#buffer#buffer_number_by_name(l:file_path),
  \ )
endfunction

function Test_relative_buffer_number_by_absolute_file_path() abort
  %bwipeout!
  let l:dir_path = strager#file#make_directory_with_files(['file.txt'])
  exec 'cd '.fnameescape(l:dir_path)
  edit file.txt
  let l:buffer_number = bufnr('%')
  let l:file_path = strager#path#join([l:dir_path, 'file.txt'])
  call assert_equal(
    \ l:buffer_number,
    \ strager#buffer#buffer_number_by_name(l:file_path),
  \ )
endfunction

function Test_absolute_buffer_number_by_relative_file_path() abort
  %bwipeout!
  let l:dir_path = strager#file#make_directory_with_files(['file.txt'])
  exec 'cd '.fnameescape(l:dir_path)
  exec 'edit '.fnameescape(strager#path#join([l:dir_path, 'file.txt']))
  let l:buffer_number = bufnr('%')
  call assert_equal(
    \ l:buffer_number,
    \ strager#buffer#buffer_number_by_name('file.txt'),
  \ )
endfunction

function Test_relative_buffer_number_by_relative_file_path() abort
  %bwipeout!
  let l:dir_path = strager#file#make_directory_with_files(['file.txt'])
  exec 'cd '.fnameescape(l:dir_path)
  edit file.txt
  let l:buffer_number = bufnr('%')
  call assert_equal(
    \ l:buffer_number,
    \ strager#buffer#buffer_number_by_name('file.txt'),
  \ )
endfunction

function Test_absolute_buffer_number_by_relative_file_path_with_similarly_named_buffers() abort
  %bwipeout!
  let l:dir_path = strager#file#make_directory_with_files([
    \ 'dir/file.txt',
    \ 'file.txt',
  \ ])
  exec 'cd '.fnameescape(l:dir_path)
  exec 'edit '.fnameescape(strager#path#join([l:dir_path, 'dir', 'file.txt']))
  exec 'split '.fnameescape(strager#path#join([l:dir_path, 'file.txt']))
  let l:buffer_number = bufnr('%')
  call assert_equal(
    \ l:buffer_number,
    \ strager#buffer#buffer_number_by_name('file.txt'),
  \ )
endfunction

function Test_relative_buffer_number_by_relative_file_path_with_similarly_named_buffers() abort
  %bwipeout!
  let l:dir_path = strager#file#make_directory_with_files([
    \ 'dir/file.txt',
    \ 'file.txt',
  \ ])
  exec 'cd '.fnameescape(l:dir_path)
  edit dir/file.txt
  split file.txt
  let l:buffer_number = bufnr('%')
  call assert_equal(
    \ l:buffer_number,
    \ strager#buffer#buffer_number_by_name('file.txt'),
  \ )
endfunction

function Test_buffer_number_by_file_name_incomplete() abort
  %bwipeout!
  let l:dir_path = strager#file#make_directory_with_files(['dir/file.txt'])
  exec 'cd '.fnameescape(l:dir_path)
  edit dir/file.txt
  call assert_equal(-1, strager#buffer#buffer_number_by_name('file.txt'))
endfunction

function Test_buffer_number_by_file_name_does_not_glob() abort
  %bwipeout!
  let l:dir_path = strager#file#make_directory_with_files(['file.txt'])
  exec 'cd '.fnameescape(l:dir_path)
  edit file.txt
  call assert_equal(-1, strager#buffer#buffer_number_by_name('fi*.txt'))
endfunction

function Test_buffer_number_by_file_name_matches_with_glob() abort
  %bwipeout!
  let l:dir_path = strager#file#make_directory_with_files(['fi*.txt'])
  exec 'cd '.fnameescape(l:dir_path)
  edit fi\*.txt
  let l:buffer_number = bufnr('%')
  call assert_equal(
    \ l:buffer_number,
    \ strager#buffer#buffer_number_by_name('fi*.txt'),
  \ )
endfunction

function Test_buffer_number_by_file_name_matches_one_with_glob() abort
  %bwipeout!
  let l:dir_path = strager#file#make_directory_with_files([
    \ 'fi*.txt',
    \ 'file.txt',
  \ ])
  exec 'cd '.fnameescape(l:dir_path)
  edit fi\*.txt
  let l:buffer_number = bufnr('%')
  split file.txt
  call assert_equal(
    \ l:buffer_number,
    \ strager#buffer#buffer_number_by_name('fi*.txt'),
  \ )
endfunction

function Test_buffer_number_by_percent_file_name() abort
  %bwipeout!
  let l:dir_path = strager#file#make_directory_with_files(['%', 'other.txt'])
  exec 'cd '.fnameescape(l:dir_path)
  edit \%
  let l:buffer_number = bufnr('%')
  split other.txt
  call assert_equal(l:buffer_number, strager#buffer#buffer_number_by_name('%'))
endfunction

function Test_buffer_number_by_hash_file_name() abort
  %bwipeout!
  let l:dir_path = strager#file#make_directory_with_files(['#', 'other.txt'])
  exec 'cd '.fnameescape(l:dir_path)
  edit \#
  let l:buffer_number = bufnr('%')
  split other.txt
  call assert_equal(l:buffer_number, strager#buffer#buffer_number_by_name('#'))
endfunction

function Test_buffer_number_by_dollar_file_name() abort
  %bwipeout!
  let l:dir_path = strager#file#make_directory_with_files(['$', 'other.txt'])
  exec 'cd '.fnameescape(l:dir_path)
  edit \$
  let l:buffer_number = bufnr('%')
  split other.txt
  call assert_equal(l:buffer_number, strager#buffer#buffer_number_by_name('$'))
endfunction

function Test_buffer_number_by_empty_name() abort
  %bwipeout!
  let l:dir_path = strager#file#make_directory_with_files(['file.txt'])
  exec 'cd '.fnameescape(l:dir_path)
  edit file.txt
  call assert_equal(-1, strager#buffer#buffer_number_by_name(''))
endfunction

call strager#test#run_all_tests()
