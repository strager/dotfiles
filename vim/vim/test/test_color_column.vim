function! Test_set_textwidth_updates_colorcolumn() abort
  call s:set_up_cc_tw_80()
  set textwidth=100
  call assert_equal('100', &g:colorcolumn)
  call assert_equal('100', &l:colorcolumn)
endfunction

function! Test_setlocal_textwidth_updates_colorcolumn() abort
  call s:set_up_cc_tw_80()
  setlocal textwidth=40
  call assert_equal('40', &l:colorcolumn)
  call assert_equal('80', &g:colorcolumn)
endfunction

function s:set_up_cc_tw_80() abort
  " FIXME(strager): Should this be part of the testing framework?
  " FIXME(strager): Should we restore after the test finishes?
  call test_override('starting', 1)

  set colorcolumn=80
  set textwidth=80
  " Make sure cc and tw were really set.
  call assert_equal('80', &g:colorcolumn)
  call assert_equal('80', &l:colorcolumn)
  call assert_equal(80, &g:textwidth)
  call assert_equal(80, &l:textwidth)
endfunction

call strager#test#run_all_tests()
