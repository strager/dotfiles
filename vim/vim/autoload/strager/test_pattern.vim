function! Test_vnm_escaping_empty_string_is_identity()
  call assert_equal('', strager#pattern#escape_vnm(''))
endfunction

function! Test_vnm_escaping_alphabet_is_identity()
  call assert_equal('hello', strager#pattern#escape_vnm('hello'))
  call assert_equal('WORLD', strager#pattern#escape_vnm('WORLD'))
endfunction

function! Test_vnm_escaping_common_special_characters_is_identity()
  call assert_equal('bra|nch', strager#pattern#escape_vnm('bra|nch'))
  call assert_equal('(group)', strager#pattern#escape_vnm('(group)'))
  call assert_equal('re+pe*at{42}', strager#pattern#escape_vnm('re+pe*at{42}'))
endfunction

function! Test_vnm_escaping_string_with_backslashes_escapes_backslash()
  call assert_equal('one\\two', strager#pattern#escape_vnm('one\two'))
  call assert_equal('one\\\\two', strager#pattern#escape_vnm('one\\two'))
  call assert_equal('\\.\\*\\(\\)', strager#pattern#escape_vnm('\.\*\(\)'))
endfunction

function! Test_pattern_from_string_matches_simple_input()
  call assert_equal(0, match('hello', strager#pattern#from_string('hello')))
  call assert_equal(0, match(
    \ 'hello world',
    \ strager#pattern#from_string('hello'),
  \ ))
  call assert_equal(4, match('why hello', strager#pattern#from_string('hello')))
endfunction

function! Test_pattern_from_string_matches_case_sensitive()
  call assert_equal(-1, match('hello', strager#pattern#from_string('HELLO')))
endfunction

function! Test_fuzz_match_pattern_from_string_equals_stridx()
  let l:rng = strager#random_mt19937#make_generator(5489)
  let l:iteration = 0
  while l:iteration < 500
    let l:prefix = s:random_string(l:rng, 0, 8)
    let l:suffix = s:random_string(l:rng, 0, 8)
    let l:needle = s:random_string(l:rng, 1, 6)
    let l:haystack = l:prefix.l:needle.l:suffix
    let l:pattern = strager#pattern#from_string(l:needle)
    let l:message = printf(
      \ "Pattern: %s\nNeedle: %s\nHaystack: %s",
      \ string(l:pattern),
      \ string(l:needle),
      \ string(l:haystack),
    \ )

    let l:match_index = match(l:haystack, l:pattern)
    let l:stridx_index = stridx(l:haystack, l:needle)
    call assert_equal(l:stridx_index, l:match_index, l:message)

    if v:errors !=# []
      break
    endif
    let l:iteration += 1
  endwhile
endfunction

function! s:random_string(rng, min_length, max_length)
  let l:length = strager#random_mt19937#next_integer(
      \ a:rng,
      \ a:min_length,
      \ a:max_length + 1,
    \ )
  let l:chars = map(
    \ range(l:length),
    \ {-> strager#random_mt19937#next_item_in_list(
      \ a:rng,
      \ s:printable_characters,
    \ )}
  \ )
  return join(l:chars, '')
endfunction

let s:printable_characters
  \ = '!"#$%&'."'".'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`'
    \ .'abcdefghijklmnopqrstuvwxyz{|}~'
let s:printable_characters = split(s:printable_characters, '\zs')

call strager#test#run_all_tests()
