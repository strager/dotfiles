function! Test_visual_shift_yank_behaves_like_nonshift_yank() abort
  %bwipeout!
  normal! ihello

  " Select 'hel' then shift-yank.
  normal 0vllY

  call assert_equal('hel', @0)
endfunction

call strager#test#run_all_tests()
