" vint: -ProhibitCommandRelyOnUser

function! Test_leader_number_switches_to_tab() abort
  %bwipeout!
  tabnew
  tabnew
  tabnew
  tabnew

  normal \1
  call assert_equal(1, tabpagenr())

  normal \2
  call assert_equal(2, tabpagenr())

  normal \5
  call assert_equal(5, tabpagenr())

  normal \4
  call strager#assert#assert_throws(
    \ {-> execute('normal \9')},
    \ 'E16:',
  \ )
  call assert_equal(4, tabpagenr())
endfunction

function! Test_leader_0_switches_to_tenth_tab() abort
  %bwipeout!
  let l:i = 0
  while l:i < 12
    tabnew
    let l:i += 1
  endwhile

  5tabnext
  normal \0
  call assert_equal(10, tabpagenr())
endfunction

call strager#test#run_all_tests()
