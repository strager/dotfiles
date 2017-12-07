let s:script_path = expand('<sfile>:p')

" **MARKER Test_function_source_location_of_user_function MARKER**
function! Test_function_source_location_of_user_function()
  let l:local = {}
  function l:local.check(function)
    let l:loc = strager#function#function_source_location(a:function)
    call assert_equal(s:test_marker_line_number(
      \ 'Test_function_source_location_of_user_function',
    \ ), l:loc.line)
    call assert_equal(
      \ 'Test_function_source_location_of_user_function',
      \ l:loc.real_name,
    \ )
    call assert_equal(
      \ 'Test_function_source_location_of_user_function',
      \ l:loc.source_name,
    \ )
    call assert_equal(s:script_path, l:loc.script_path)
  endfunction

  " User function by name string.
  call l:local.check('Test_function_source_location_of_user_function')
  " User function by funcref.
  call l:local.check(funcref('Test_function_source_location_of_user_function'))
  " User function by partial.
  call l:local.check(funcref(
    \ 'Test_function_source_location_of_user_function',
    \ ['args', 'go', 'here'],
  \ ))
endfunction

function! Test_function_source_location_of_script_function()
  let l:local = {}
  function l:local.check(function)
    let l:loc = strager#function#function_source_location(a:function)
    call assert_equal(
      \ s:test_marker_line_number('s:script_function'),
      \ l:loc.line,
    \ )
    call assert_equal(
      \ "\x80\xfdR".s:sid().'_script_function',
      \ l:loc.real_name,
    \ )
    call assert_equal(
      \ 's:script_function',
      \ l:loc.source_name,
    \ )
    call assert_equal(s:script_path, l:loc.script_path)
  endfunction

  " Script function by real name string.
  call l:local.check(get(funcref('s:script_function'), 'name'))
  " Script function by SNR name string.
  call l:local.check('<SNR>'.s:sid().'_script_function')
endfunction

function! Test_function_source_location_of_built_in_function()
  " Built-in function by name string.
  let l:loc = strager#function#function_source_location('getbufinfo')
  call assert_equal(v:none, l:loc.line)
  call assert_equal('getbufinfo', l:loc.real_name)
  call assert_equal(v:none, l:loc.script_path)
  call assert_equal(v:none, l:loc.source_name)

  " Built-in function by dynamic funcref.
  let l:loc = strager#function#function_source_location(function('getbufinfo'))
  call assert_equal(v:none, l:loc.line)
  call assert_equal('getbufinfo', l:loc.real_name)
  call assert_equal(v:none, l:loc.script_path)
  call assert_equal(v:none, l:loc.source_name)
endfunction

" Test that s:function_with_common_prefix isn't confused for
" s:function_with_common_prefix2.
function! Test_function_source_location_of_functions_with_common_prefix()
  let l:loc = strager#function#function_source_location(
    \ funcref('s:function_with_common_prefix'),
  \ )
  call assert_equal(
    \ s:test_marker_line_number('s:function_with_common_prefix'),
    \ l:loc.line,
  \ )
endfunction

" **MARKER s:script_function MARKER**
function! s:script_function()
endfunction

function! s:function_with_common_prefix_()
endfunction

" **MARKER s:function_with_common_prefix MARKER**
function! s:function_with_common_prefix()
endfunction

function! s:function_with_common_prefix2()
endfunction

function! s:sid()
  " See: :help <SID>
  return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_sid$')
endfun

function! s:test_marker_line_number(marker_name)
  " FIXME(strager): Is this the correct way to escape?
  let l:pattern = '\*\*MARKER '.escape(a:marker_name, '').' MARKER\*\*'
  let l:cur_line_number = 1
  for l:line in readfile(s:script_path)
    if match(l:line, l:pattern) != -1
      " Return the number of the line after the marker.
      return l:cur_line_number + 1
    endif
    let l:cur_line_number += 1
  endfor
  throw 'Could not find marker: '.a:marker_name
endfunction

call strager#test#run_all_tests()
