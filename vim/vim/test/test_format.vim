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
  new
  exec 'edit '.fnameescape(s:script_dir_path.'/test_format_helper.py')
  setlocal readonly
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
    let l:diff_output = execute(printf(
      \ 'silent !diff -u -- %s %s',
      \ shellescape(l:buffer_path),
      \ shellescape(a:expected_path),
    \ ))
    call assert_report(
      \ 'Expected the current buffer to have the same contents as the file '
        \ .a:expected_path,
    \ )
    " FIXME(strager): This is broken on Windows and likely other platforms too.
    for l:diff_line in split(@", '\n')
      call add(v:errors, 'diff: '.l:diff_line)
    endfor
  endif
endfunction

call strager#test#run_all_tests()
