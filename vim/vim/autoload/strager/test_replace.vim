function! Test_prompt_replacing_current_word_modifies_all_occurrences_on_lines() abort
  %bwipeout!
  normal! ithis is a test
  normal! owe are trying to test the replace feature in this test
  normal! othis is only a test

  " Move the cursor onto the word 'test'.
  3
  normal! $

  call feedkeys(
    \ ":call strager#replace#prompt_replace_current_word()\<CR>"
    \ ."\<BS>\<BS>\<BS>\<BS>"
    \ ."ruse"
    \ ."\<CR>",
    \ 'tx',
  \ )

  call assert_equal([
    \ 'this is a ruse',
    \ 'we are trying to ruse the replace feature in this ruse',
    \ 'this is only a ruse',
  \ ], strager#buffer#get_current_buffer_lines())
endfunction

function! Test_replacing_current_word_replaces_only_whole_word() abort
  %bwipeout!
  normal! iI eat, they are eating, she eats, and he eats, all the wheat

  " Move the cursor to the word 'eat'.
  normal! 0ll

  call feedkeys(
    \ ":call strager#replace#prompt_replace_current_word()\<CR>"
    \ ."\<BS>\<BS>\<BS>"
    \ ."nommed"
    \ ."\<CR>",
    \ 'tx',
  \ )

  call assert_equal([
    \ 'I nommed, they are eating, she eats, and he eats, all the wheat',
  \ ], strager#buffer#get_current_buffer_lines())
endfunction

" @@@ case sensitive?

function! Test_replacing_current_word_respects_iskeyword_and_allows_magic_pattern_characters() abort
  %bwipeout!
  setlocal iskeyword+=$,*,/
  normal! ia /fl*wer$ a /fwer$ a /flwer$ a /fl*wer$

  " Move the cursor to the second word 'flower$'.
  normal! $B

  call feedkeys(
    \ ":call strager#replace#prompt_replace_current_word()\<CR>"
    \ ."\<Left>s\<CR>",
    \ 'tx',
  \ )

  call assert_equal([
    \ 'a /fl*wers$ a /fwer$ a /flwer$ a /fl*wers$',
  \ ], strager#buffer#get_current_buffer_lines())
endfunction

function! Test_replacing_visual_selection_includes_whitespace() abort
  %bwipeout!
  normal! ia taco is a taco if a taco tacos

  " Move the cursor to 'a tac'.
  normal! 0

  call feedkeys(
    \ "vllll"
    \ .":\<BS>\<BS>\<BS>\<BS>\<BS>"
    \ ."call strager#replace#prompt_replace_visual_selection()\<CR>"
    \ ."\<BS>\<BS>\<BS>\<BS>\<BS>my burrit"
    \ ."\<CR>",
    \ 'tx',
  \ )

  call assert_equal([
    \ 'my burrito is my burrito if my burrito tacos',
  \ ], strager#buffer#get_current_buffer_lines())
endfunction

call strager#test#run_all_tests()
