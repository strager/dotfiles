function strager#assert#assert_throws(function, error, ...)
  let l:msg = get(a:000, 0, v:none)
  try
    call a:function()
    if l:msg ==# v:none
      call assert_report('Function should have thrown an error, but did not')
    else
      call assert_report(l:msg)
    endif
  catch
    if l:msg ==# v:none
      call assert_exception(a:error)
    else
      call assert_exception(a:error, l:msg)
    endif
  endtry
endfunction

function strager#assert#take_assertion_failure_messages()
  let l:errors = v:errors
  let l:error_messages = map(copy(l:errors), {_, error -> matchlist(error, '^[^:]*: \(.*\)$')[1]})
  let v:errors = []
  return l:error_messages
endfunction

function strager#assert#assert_matches_unordered(expected_patterns, actual_strings)
  if len(a:expected_patterns) !=# len(a:actual_strings)
    call assert_report(printf(
      \ 'Expected %d strings but got %d: %s',
      \ len(a:expected_patterns),
      \ len(a:actual_strings),
      \ string(a:actual_strings),
    \ ))
    return
  endif

  let l:length = len(a:expected_patterns)
  if l:length ==# 0
    " Do nothing.
  elseif l:length ==# 1
    call assert_match(a:expected_patterns[0], a:actual_strings[0])
  elseif l:length ==# 2
    call s:assert_matches_unordered_2(a:expected_patterns, a:actual_strings)
  else
    throw printf('Asserting with %d patterns is not implemented', l:length)
  endif
endfunction

function s:assert_matches_unordered_2(expected_patterns, actual_strings)
  let l:p0_matches_s0 = s:is_match(a:actual_strings[0], a:expected_patterns[0])
  let l:p1_matches_s0 = s:is_match(a:actual_strings[0], a:expected_patterns[1])
  let l:p0_matches_s1 = s:is_match(a:actual_strings[1], a:expected_patterns[0])
  let l:p1_matches_s1 = s:is_match(a:actual_strings[1], a:expected_patterns[1])

  if l:p1_matches_s0 && l:p0_matches_s1
    return
  endif
  if l:p0_matches_s0 && l:p1_matches_s1
    return
  endif

  let l:bad_patterns = []
  if (!l:p0_matches_s0 || l:p1_matches_s0) && (l:p1_matches_s1 || !l:p0_matches_s1)
    call add(l:bad_patterns, a:expected_patterns[0])
  endif
  if (l:p0_matches_s0 || !l:p1_matches_s0) && (!l:p1_matches_s1 || l:p0_matches_s1)
    call add(l:bad_patterns, a:expected_patterns[1])
  endif

  let l:bad_strings = []
  if (!l:p0_matches_s0 || l:p0_matches_s1) && (l:p1_matches_s1 || !l:p1_matches_s0)
    call add(l:bad_strings, a:actual_strings[0])
  endif
  if (l:p0_matches_s0 || !l:p0_matches_s1) && (!l:p1_matches_s1 || l:p1_matches_s0)
    call add(l:bad_strings, a:actual_strings[1])
  endif

  call assert_report(s:format_failed_pattern_matches(
    \ l:bad_patterns,
    \ l:bad_strings,
  \ ))
endfunction

function s:is_match(string, pattern)
  return match(a:string, a:pattern) !=# -1
endfunction

function s:format_failed_pattern_matches(patterns, strings)
  if len(a:patterns) ==# 0 || len(a:strings) ==# 0
    throw 'Expected at least one failed pattern and string'
  endif
  let l:string_words = s:format_list_as_strings(a:strings, ' or ')
  if len(a:patterns) > 1
    let l:pattern_words = s:format_list_as_strings(a:patterns, ' and ')
    return printf(
      \ 'Patterns %s do not match %s',
      \ l:pattern_words,
      \ l:string_words,
    \ )
  else
    return printf(
      \ 'Pattern %s does not match %s',
      \ string(a:patterns[0]),
      \ l:string_words,
    \ )
  endif
endfunction

function s:format_list_as_strings(items, joiner)
  return join(map(copy(a:items), {_, item -> string(item)}), a:joiner)
endfunction
