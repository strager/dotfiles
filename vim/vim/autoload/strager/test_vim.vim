function! Test_set_efm_with_escaped_empty_string()
  call execute('set efm='.strager#vim#escape_for_set(''))
  call assert_equal('', &efm)
endfunction

function! Test_set_efm_with_escaped_letters()
  call execute('set efm='.strager#vim#escape_for_set('helloworld'))
  call assert_equal('helloworld', &efm)
endfunction

function! Test_set_efm_with_escaped_letters_and_space()
  call execute('set efm='.strager#vim#escape_for_set('hello world'))
  call assert_equal('hello world', &efm)
endfunction

function! Test_set_efm_with_escaped_spaces()
  call execute('set efm='.strager#vim#escape_for_set('   '))
  call assert_equal('   ', &efm)
endfunction

function! Test_set_efm_with_escaped_letters_and_backslash()
  call execute('set efm='.strager#vim#escape_for_set('hello\world'))
  call assert_equal('hello\world', &efm)
endfunction

function! Test_set_efm_with_escaped_letters_and_double_quotes()
  call execute('set efm='.strager#vim#escape_for_set('hello"world"'))
  call assert_equal('hello"world"', &efm)
endfunction

function! Test_set_efm_with_escaped_letters_and_spaces_and_pipe()
  call execute('set efm='.strager#vim#escape_for_set('hello | world'))
  call assert_equal('hello | world', &efm)
endfunction

function! Test_set_efm_with_escaped_env_path()
  call execute('set efm='.strager#vim#escape_for_set('$PATH'))
  call assert_equal('$PATH', &efm)
endfunction

" TODO(strager): Make this work. I think it's impossible.
function! XTest_set_makeprg_with_escaped_env_home()
  call execute('set makeprg='.strager#vim#escape_for_set_makeprg('$HOME'))
  call assert_equal('$HOME', &makeprg)
endfunction

function! Test_escaped_set_makeprg_with_pipeline()
  call execute('set makeprg='.strager#vim#escape_for_set_makeprg('echo hello world | cut -c4-'))
  set errorformat=%+Glo\ world
  silent make
  let l:items = getqflist()
  call assert_equal(1, len(l:items))
  call assert_true(l:items[0].valid)
  call assert_equal('lo world', l:items[0].text)
endfunction

" TODO(strager): Test makeprg with '${HOME}'.
" TODO(strager): Test makeprg with '%HOME%'.
" TODO(strager): Test makeprg with '`=expression`'.
" TODO(strager): Test makeprg with '~'.

call strager#test#run_all_tests()
