function! strager#cxx_symbol#get_conceal_pattern()
  let l:name_prefix = ''
    \ .s:nested_name()
    \ .s:any_of([
      \ ' \ze[^:]\+<',
      \ ' '.s:nested_name().'\ze::',
      \ '\ze::',
    \ ])
  return s:any_of([
    \ 'vtable for \zs',
    \ l:name_prefix,
    \ '<\zs'.s:template_parameters().'\ze>',
    \ '(\zs'.s:function_parameters().'\ze)',
  \ ])
endfunction

" A ::-separated list of simpler names. A nested_name can represent a namespace
" or a type.
"
" Examples:
"
" * std
" * std::filesystem
" * std::thread
" * std::atomic<char>
" * std::vector<int>::const_iterator
function! s:nested_name()
  return s:unqualified_name().'\%(::'.s:unqualified_name().'\)*'
endfunction

" The name of a function, namespace, or type.
"
" * Excludes function parameters.
" * Excludes preceeding namespaces.
" * Includes template parameters.
"
" Examples:
"
" * std
" * (anonymous namespace)
" * get_id
" * vector<int>
" * pair<int, std::basic_string<char, std::char_traits<char>, std::allocator<char> > >
" * sort<int*>
function! s:unqualified_name()
  return s:any_of([
    \ '([^()]*)',
    \ '[^()<> ]\+\%(<'.s:template_parameters().'>\)\?',
  \ ])
endfunction

" Any number of function parameters, excluding surrounding parentheses
function! s:function_parameters()
  return '[^()]\+'
endfunction

" Any number of template parameters, excluding surrounding angle brackets.
function! s:template_parameters()
  let s:max_nesting = 3
  return s:nested_surrounded('<', '[^<>]', '>', s:max_nesting)
endfunction

function! s:nested_surrounded(before, leaf, after, depth)
  let l:pattern = a:leaf
  for l:_ in range(a:depth)
    let l:pattern = s:any_of([a:leaf, a:before.l:pattern.a:after]).'\+'
  endfor
  return l:pattern
endfunction

function! s:any_of(patterns)
  return '\%('.join(a:patterns, '\|').'\)'
endfunction
