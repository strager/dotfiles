let s:test_script_path = expand('<sfile>')

function! Test_script_number_of_test_matches_sfile_sid()
  call assert_equal(
    \ str2nr(s:sid()),
    \ strager#script#number_of_loaded_script(s:test_script_path),
  \ )
endfunction

function! Test_script_number_of_test_by_name_does_not_match()
  let l:script_name = fnamemodify(s:test_script_path, ':t')
  call strager#assert#assert_throws(
    \ {-> strager#script#number_of_loaded_script(l:script_name)},
    \ 'ES005:',
  \ )
endfunction

function! s:sid()
  " See: :help <SID>
  return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_sid$')
endfun

call strager#test#run_all_tests()
