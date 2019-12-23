function! Test_conceal_symbols_not_needing_conceal() abort
  call assert_equal([], s:conceal('my_variable'))
  call assert_equal([], s:conceal('my_function()'))
  call assert_equal([], s:conceal('my_function_template<>()'))
endfunction

function! Test_conceal_drops_function_parameter_types() abort
  call assert_equal(['int'], s:conceal('my_function(int)'))
  call assert_equal(['int, char'], s:conceal('my_function(int, char)'))
endfunction

function! Test_conceal_drops_function_parameters_with_namespaced_types() abort
  call assert_equal(
    \ ['std::__exception_ptr::exception_ptr'],
    \ s:conceal('rethrow_exception(std::__exception_ptr::exception_ptr)'),
  \ )
endfunction

function! Test_conceal_drops_function_return_type() abort
  call assert_equal(['void '], s:conceal('void function_template<>()'))
endfunction

function! Test_conceal_drops_namespaces() abort
  call assert_equal(['std'], s:conceal('std::terminate'))
  call assert_equal(['std::filesystem'], s:conceal('std::filesystem::is_fifo'))
endfunction

function! Test_conceal_drops_anonymous_namespaces() abort
  call assert_equal(
    \ ['(anonymous namespace)'],
    \ s:conceal('(anonymous namespace)::g_singleton'),
  \ )
  call assert_equal(
    \ ['benchmark::(anonymous namespace)'],
    \ s:conceal('benchmark::(anonymous namespace)::kSmallSIUnits'),
  \ )
endfunction

function! Test_conceal_drops_function_return_type_and_namespace() abort
  call assert_equal(
    \ ['void ns::detail'],
    \ s:conceal('void ns::detail::function_template<>()'),
  \ )
endfunction

function! Test_conceal_drops_function_template_arguments() abort
  call assert_equal(['int'], s:conceal('my_function_template<int>()'))
  call assert_equal(
    \ ['int, my_struct_template<unsigned long> '],
    \ s:conceal('my_function_template<int, my_struct_template<unsigned long> >()'),
  \ )
endfunction

function! Test_conceal_drops_function_template_parameters_with_namespaced_types() abort
  call assert_equal(
    \ ['std::type_info'],
    \ s:conceal('my_function_template<std::type_info>()'),
  \ )
  call assert_equal(
    \ ['std::pair<int, char> '],
    \ s:conceal('my_function_template<std::pair<int, char> >()'),
  \ )
  call assert_equal(
    \ ['std::pair<int, std::pair<int, int> > '],
    \ s:conceal('my_function_template<std::pair<int, std::pair<int, int> > >()'),
  \ )
  call assert_equal(
    \ ['std::pair<std::optional<int>, std::optional<char> > '],
    \ s:conceal('my_function_template<std::pair<std::optional<int>, std::optional<char> > >()'),
  \ )
endfunction

function! Test_conceal_drops_function_template_class_template_return_type() abort
  call assert_equal(
    \ ['pair<int, char> ', 'int, char'],
    \ s:conceal('pair<int, char> make_pair<int, char>()'),
  \ )
  call assert_equal(
    \ ['pair<int, char> std', 'int, char'],
    \ s:conceal('pair<int, char> std::make_pair<int, char>()'),
  \ )
  call assert_equal(
    \ ['std::pair<int, char> ', 'int, char'],
    \ s:conceal('std::pair<int, char> make_pair<int, char>()'),
  \ )
  call assert_equal(
    \ ['std::pair<int, char> std', 'int, char'],
    \ s:conceal('std::pair<int, char> std::make_pair<int, char>()'),
  \ )
endfunction

function! Test_conceal_drops_class_template_parameters() abort
  call assert_equal(['int'], s:conceal('my_class_template<int>'))
  call assert_equal(
    \ ['std::pair<char, int> '],
    \ s:conceal('my_class_template<std::pair<char, int> >'),
  \ )
endfunction

function! Test_conceal_with_extraneous_trailing_gt_drops_class_template_parameters() abort
  call assert_equal(['int'], s:conceal('my_class_template<int>'))
  call assert_equal(
    \ ['std::pair<char, int> '],
    \ s:conceal('my_class_template<std::pair<char, int> >>'),
  \ )
endfunction

function! Test_conceal_drops_class_with_template_parameters() abort
  call assert_equal(
    \ ['my_class_template<int>'],
    \ s:conceal('my_class_template<int>::f()'),
  \ )
  call assert_equal(
    \ ['my_class_template<int>'],
    \ s:conceal('my_class_template<int>::g_singleton'),
  \ )
  call assert_equal(['a<b<c<d> > >'], s:conceal('a<b<c<d> > >::f()'))
endfunction

function! Test_conceal_preserves_vtable_prefix() abort
  call assert_equal([], s:conceal('vtable for ConsoleReporter'))
  call assert_equal(
    \ ['benchmark'],
    \ s:conceal('vtable for benchmark::ConsoleReporter'),
  \ )
  call assert_equal(
    \ ['std::__1', 'char, std::__1::char_traits<char> '],
    \ s:conceal('vtable for std::__1::basic_ofstream<char, std::__1::char_traits<char> >'),
  \ )
endfunction

function! s:conceal(demangled_symbol) abort
  let l:pattern = strager#cxx_symbol#get_conceal_pattern()
  let l:matches = []
  let l:cur_index = 0
  while l:cur_index < len(a:demangled_symbol)
    let [l:match_string, l:_match_start_index, l:match_end_index]
      \ = matchstrpos(a:demangled_symbol, l:pattern, l:cur_index)
    if l:match_end_index == -1
      break
    endif
    if l:match_string ==# ''
      " TODO(strager): Refactor the pattern to avoid empty matches.
    else
      call add(l:matches, l:match_string)
    endif
    if l:match_end_index <= l:cur_index
      throw 'Pattern matched but consumed no input'
    endif
    let l:cur_index = l:match_end_index
  endwhile
  return l:matches
endfunction

call strager#test#run_all_tests()
