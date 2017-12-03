let s:script_path = expand('<sfile>:p')
let s:script_dir_path = fnamemodify(s:script_path, ':h')

function! Test_ninja_cd_compile_error_from_empty_buffer()
  call s:set_up()
  set makeprg=ninja
  cd test_c_make_ninja_helper
  silent make
  call s:assert_cursor_should_have_jumped_to_error()
endfunction

function! Test_ninja_cd_compile_error_from_source_buffer()
  call s:set_up()
  set makeprg=ninja
  cd test_c_make_ninja_helper
  edit program.c
  silent make
  call s:assert_cursor_should_have_jumped_to_error()
endfunction

function! Test_ninja_relative_compile_error_from_empty_buffer()
  call s:set_up()
  set makeprg=ninja\ -C\ test_c_make_ninja_helper
  silent make
  call s:assert_cursor_should_have_jumped_to_error()
endfunction

function! Test_ninja_relative_compile_error_from_source_buffer()
  call s:set_up()
  echomsg &efm
  set makeprg=ninja\ -C\ test_c_make_ninja_helper
  edit test_c_make_ninja_helper/program.c
  echomsg &efm
  silent make
  call s:assert_cursor_should_have_jumped_to_error()
endfunction

function! s:set_up()
  cd `=s:script_dir_path`
  %bwipeout
endfunction

function! s:assert_cursor_should_have_jumped_to_error()
  let [l:_buffer_number, l:line, l:column, l:_offset, l:_curswant] = getcurpos()
  let l:buffer_name = bufname('')
  call assert_notequal('', l:buffer_name)
  if l:buffer_name !=# ''
    call assert_equal(
      \ strager#path#join([
        \ s:script_dir_path,
        \ 'test_c_make_ninja_helper',
        \ 'program.c',
      \ ]),
      \ fnamemodify(l:buffer_name, ':p'),
    \ )
    call assert_equal(3, l:line)
    call assert_equal(10, l:column)
  endif
endfunction

call strager#test#run_all_tests()
