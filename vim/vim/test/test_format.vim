let s:script_path = expand('<sfile>:p')
let s:script_dir_path = fnamemodify(s:script_path, ':h')

function! Test_python_insert_does_not_wrap_lines() abort
  call s:set_up_python_helper_source()
  " Append to the long line.
  call cursor(11, 1)
  silent! normal! A + (a + b + c)
  call s:assert_buffer_contents_match_expected(
    \ s:script_dir_path
      \ .'/test_format_expected_python_insert_does_not_wrap_lines.py',
  \ )
endfunction

function! s:set_up_python_helper_source() abort
  %bwipeout!
  exec 'edit '.fnameescape(s:script_dir_path.'/test_format_helper.py')
  setlocal readonly
endfunction

function! Test_c_indent_after_case() abort
  call s:set_up_c_helper_source()
  " Reindent 'int x;'.
  call cursor(7, 1)
  silent! normal! ==
  call s:assert_buffer_contents_match_expected(
    \ s:script_dir_path.'/test_format_helper.c',
  \ )
endfunction

function! Test_c_opening_new_line_after_comment_line_comments_new_line() abort
  call s:set_up_c_helper_source()
  /Test line which is entirely a comment

  normal otest

  call assert_equal('// test', getline('.'))
endfunction

function! Test_c_opening_new_line_after_trailing_comment_does_not_comment_new_line() abort
  call s:set_up_c_helper_source()
  /Test line with a trailing comment

  normal otest

  call assert_equal('test', getline('.'))
endfunction

function! s:set_up_c_helper_source() abort
  %bwipeout!
  exec 'edit '.fnameescape(s:script_dir_path.'/test_format_helper.c')
  setlocal readonly
  setlocal sw=2
endfunction

function! Test_line_break_after_parens_and_colon_does_not_indent_silly() abort
  for l:filetype in ['hgcommit', 'gitcommit', 'markdown']
    %bwipeout!
    let &filetype = l:filetype
    normal ifix(component): I did it

    normal ohello
    call assert_equal(
      \ ['fix(component): I did it', 'hello'],
      \ strager#buffer#get_current_buffer_lines(),
    \ )
  endfor
endfunction

function! s:assert_buffer_contents_match_expected(expected_path) abort
  let l:buffer_path = tempname()
  exec 'silent write '.fnameescape(l:buffer_path)
  if has('win32')
    let l:compare_command_template = 'comp /M %s %s'
  else
    let l:compare_command_template = 'cmp -b -- %s %s'
  endif
  exec printf(
    \ 'silent !'.l:compare_command_template,
    \ shellescape(l:buffer_path),
    \ shellescape(a:expected_path),
  \ )
  if v:shell_error != 0
    let l:diff_lines = systemlist(printf(
      \ 'diff -u -- %s %s',
      \ shellescape(l:buffer_path),
      \ shellescape(a:expected_path),
    \ ))
    call assert_report(
      \ 'Expected the current buffer to have the same contents as the file '
        \ .a:expected_path,
    \ )
    " FIXME(strager): This is broken on Windows and likely other platforms too.
    for l:diff_line in l:diff_lines
      call add(v:errors, 'diff: '.l:diff_line)
    endfor
  endif
endfunction

call strager#test#run_all_tests()
