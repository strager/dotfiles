function! Test_parse_identifier() abort
  " TODO(strager): m_, s_, etc. prefix.
  " TODO(strager): Support shouty words in camel case (e.g. XmlHTTPRequest).

  call s:assert_parsed('_', 'unknown', ['_', ''])
  call s:assert_parsed('_123', 'unknown', ['_', '123', ''])

  call s:assert_parsed('hello_World', 'unknown', ['', 'hello', 'World', ''])
  call s:assert_parsed('One_two_Three', 'unknown', ['', 'One', 'two', 'Three', ''])
  call s:assert_parsed('One_Two_three', 'unknown', ['', 'One', 'Two', 'three', ''])
  call s:assert_parsed('HELLO_my_World', 'unknown', ['', 'HELLO', 'my', 'World', ''])
  call s:assert_parsed('HELLO_My_world', 'unknown', ['', 'HELLO', 'My', 'world', ''])
  call s:assert_parsed('hello_MY_world', 'unknown', ['', 'hello', 'MY', 'world', ''])
  call s:assert_parsed('one_twoThree', 'unknown', ['', 'one', 'two', 'Three', ''])
  call s:assert_parsed('oneTwo_three', 'unknown', ['', 'one', 'Two', 'three', ''])

  call s:assert_parsed('a', 'lower', ['', 'a', ''])
  call s:assert_parsed('hello', 'lower', ['', 'hello', ''])
  call s:assert_parsed('hello123', 'lower', ['', 'hello123', ''])
  call s:assert_parsed('_a', 'lower', ['_', 'a', ''])
  call s:assert_parsed('a_', 'lower', ['', 'a', '_'])

  call s:assert_parsed('Hello', 'upper', ['', 'Hello', ''])
  call s:assert_parsed('Hello123', 'upper', ['', 'Hello123', ''])

  call s:assert_parsed('A', 'shout', ['', 'A', ''])
  call s:assert_parsed('HELLO', 'shout', ['', 'HELLO', ''])
  call s:assert_parsed('HELLO123', 'shout', ['', 'HELLO123', ''])

  call s:assert_parsed('helloWorld', 'lower_camel', ['', 'hello', 'World', ''])

  call s:assert_parsed('HelloWorld', 'upper_camel', ['', 'Hello', 'World', ''])

  call s:assert_parsed('hello_world', 'lower_snake', ['', 'hello', 'world', ''])
  call s:assert_parsed('hello__world', 'lower_snake', ['', 'hello', 'world', ''])
  call s:assert_parsed('hello_123', 'lower_snake', ['', 'hello', '123', ''])

  call s:assert_parsed('Hello_World', 'upper_snake', ['', 'Hello', 'World', ''])
  call s:assert_parsed('Hello__World', 'upper_snake', ['', 'Hello', 'World', ''])
  call s:assert_parsed('Hello_HTML_World', 'upper_snake', ['', 'Hello', 'HTML', 'World', ''])
  call s:assert_parsed('HTML_Hello', 'upper_snake', ['', 'HTML', 'Hello', ''])

  call s:assert_parsed('Hello_world', 'title_snake', ['', 'Hello', 'world', ''])
  call s:assert_parsed('__Hello_world__', 'title_snake', ['__', 'Hello', 'world', '__'])
  call s:assert_parsed('Hello__world', 'title_snake', ['', 'Hello', 'world', ''])
  call s:assert_parsed('HTML_hello', 'title_snake', ['', 'HTML', 'hello', ''])

  call s:assert_parsed('HELLO_WORLD', 'shout_snake', ['', 'HELLO', 'WORLD', ''])
endfunction

function! s:assert_parsed(identifier, expected_style, expected_parts) abort
  let l:result = strager#identifier#parse(a:identifier)
  call assert_equal(a:expected_style, l:result.style)
  call assert_equal(a:expected_parts, l:result.parts)
endfunction

function! Test_reformat() abort
  " TODO(strager): Support not changing shouty words to upper.

  call s:assert_reformatted(['', 'hello', ''], 'upper', 'Hello')
  call s:assert_reformatted(['', 'Hello', ''], 'upper', 'Hello')
  call s:assert_reformatted(['', 'HELLO', ''], 'upper', 'Hello')

  call s:assert_reformatted(['', 'hello', ''], 'lower', 'hello')
  call s:assert_reformatted(['', 'Hello', ''], 'lower', 'hello')
  call s:assert_reformatted(['', 'HELLO', ''], 'lower', 'hello')

  call s:assert_reformatted(['', 'hello', ''], 'shout', 'HELLO')
  call s:assert_reformatted(['', 'Hello', ''], 'shout', 'HELLO')
  call s:assert_reformatted(['', 'HELLO', ''], 'shout', 'HELLO')

  call s:assert_reformatted(['', 'hello', 'world', ''], 'shout_snake', 'HELLO_WORLD')
  call s:assert_reformatted(['', 'Hello', 'world', ''], 'shout_snake', 'HELLO_WORLD')
  call s:assert_reformatted(['', 'HELLO', 'world', ''], 'shout_snake', 'HELLO_WORLD')

  call s:assert_reformatted(['', 'hello', 'world', ''], 'upper_snake', 'Hello_World')
  call s:assert_reformatted(['', 'Hello', 'world', ''], 'upper_snake', 'Hello_World')
  call s:assert_reformatted(['', 'HELLO', 'world', ''], 'upper_snake', 'Hello_World')

  call s:assert_reformatted(['', 'hello', 'world', ''], 'lower_snake', 'hello_world')
  call s:assert_reformatted(['', 'Hello', 'world', ''], 'lower_snake', 'hello_world')
  call s:assert_reformatted(['', 'HELLO', 'world', ''], 'lower_snake', 'hello_world')

  call s:assert_reformatted(['', 'hello', 'world', ''], 'title_snake', 'Hello_world')
  call s:assert_reformatted(['', 'Hello', 'world', ''], 'title_snake', 'Hello_world')
  call s:assert_reformatted(['', 'HELLO', 'world', ''], 'title_snake', 'Hello_world')
  call s:assert_reformatted(['', 'hello', 'World', ''], 'title_snake', 'Hello_world')
  call s:assert_reformatted(['', 'Hello', 'World', ''], 'title_snake', 'Hello_world')
  call s:assert_reformatted(['', 'HELLO', 'World', ''], 'title_snake', 'Hello_world')

  call s:assert_reformatted(['', 'hello', 'world', ''], 'lower_camel', 'helloWorld')
  call s:assert_reformatted(['', 'Hello', 'world', ''], 'lower_camel', 'helloWorld')
  call s:assert_reformatted(['', 'HELLO', 'world', ''], 'lower_camel', 'helloWorld')

  call s:assert_reformatted(['', 'hello', 'world', ''], 'upper_camel', 'HelloWorld')
  call s:assert_reformatted(['', 'Hello', 'world', ''], 'upper_camel', 'HelloWorld')
  call s:assert_reformatted(['', 'HELLO', 'world', ''], 'upper_camel', 'HelloWorld')

  call s:assert_reformatted(['_', 'hello', '_'], 'upper', '_Hello_')
endfunction

function! s:assert_reformatted(parts, new_style, expected_identifier) abort
  let l:result = strager#identifier#reformat(a:parts, a:new_style)
  call assert_equal(a:expected_identifier, l:result)
endfunction

function! Test_cycle_format() abort
  call assert_equal(
    \ 'helloWorld',
    \ strager#identifier#cycle_format(
      \ 'hello_world',
      \ {
        \ 'lower_snake': 'lower_camel',
      \ },
    \ ),
  \ )

  call assert_equal(
    \ 'hello_world',
    \ strager#identifier#cycle_format(
      \ 'helloWorld',
      \ {
        \ 'lower_snake': 'lower_camel',
        \ 'lower_camel': 'lower_snake',
      \ },
    \ ),
  \ )

  call assert_equal(
    \ 'Hello_World',
    \ strager#identifier#cycle_format(
      \ 'HELLO_WORLD',
      \ {
        \ 'lower_snake': 'lower_camel',
        \ 'lower_camel': 'lower_snake',
        \ 'unknown': 'upper_snake',
      \ },
    \ ),
  \ )
endfunction

function! Test_cycle_format_under_cursor() abort
  %bwipeout!
  normal! i(hello_world)
  " Move the cursor to the 'o' in 'hello'.
  normal! 0fo

  call strager#identifier#cycle_format_under_cursor({
    \ 'lower_snake': 'lower_camel',
  \ })

  call assert_equal('(helloWorld)', getline('.'))
endfunction

call strager#test#run_all_tests()
