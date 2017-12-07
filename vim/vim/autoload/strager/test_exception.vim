let s:script_path = expand('<sfile>:p')

function! Test_parse_throwpoint_from_user_function()
  let l:throwpoint = v:none
  try
    " **MARKER Test_parse_throwpoint_from_user_function MARKER**
    throw 'My error'
  catch
    let l:throwpoint = v:throwpoint
  endtry
  let l:frames = strager#exception#parse_throwpoint(l:throwpoint)
  let [l:throw_frame; _] = l:frames

  call assert_equal(
    \ 'Test_parse_throwpoint_from_user_function',
    \ l:throw_frame.function.real_name,
  \ )
  call assert_equal(s:script_path, l:throw_frame.script_path)
  call assert_equal(
    \ s:test_marker_line_number('Test_parse_throwpoint_from_user_function'),
    \ l:throw_frame.line,
  \ )
endfunction

function! Test_parse_throwpoint_from_built_in_function()
  let l:throwpoint = v:none
  try
    " **MARKER Test_parse_throwpoint_from_built_in_function MARKER**
    call split([])
  catch
    let l:throwpoint = v:throwpoint
  endtry
  let l:frames = strager#exception#parse_throwpoint(l:throwpoint)
  let [l:throw_frame; _] = l:frames

  call assert_equal(
    \ 'Test_parse_throwpoint_from_built_in_function',
    \ l:throw_frame.function.real_name,
  \ )
  call assert_equal(s:script_path, l:throw_frame.script_path)
  call assert_equal(
    \ s:test_marker_line_number('Test_parse_throwpoint_from_built_in_function'),
    \ l:throw_frame.line,
  \ )
endfunction

function! Test_parse_throwpoint_through_built_in_function()
  let l:throwpoint = v:none
  try
    " **MARKER Test_parse_throwpoint_through_built_in_function callee MARKER**
    let L:lambda = {_, _ -> reference_to_undefined_name}
    " **MARKER Test_parse_throwpoint_through_built_in_function caller MARKER**
    call map([1], L:lambda)
  catch
    let l:throwpoint = v:throwpoint
  endtry
  let l:frames = strager#exception#parse_throwpoint(l:throwpoint)
  let [l:throw_frame, l:call_frame; _] = l:frames

  call assert_equal(
    \ 'Test_parse_throwpoint_through_built_in_function',
    \ l:throw_frame.function.real_name,
  \ )
  call assert_equal(s:script_path, l:throw_frame.script_path)
  call assert_equal(s:test_marker_line_number(
    \ 'Test_parse_throwpoint_through_built_in_function callee',
  \ ), l:throw_frame.line)

  " map() does *not* introduce a frame.
  call assert_notequal(
      \ 'Test_parse_throwpoint_through_built_in_function',
      \ l:call_frame.function.real_name)
  if l:call_frame.script_path ==# s:script_path
    call assert_notequal(s:test_marker_line_number(
      \ 'Test_parse_throwpoint_through_built_in_function caller',
    \ ), l:call_frame.line)
  endif
endfunction

function! Test_parse_throwpoint_from_script_function()
  let l:throwpoint = v:none
  try
    " **MARKER Test_parse_throwpoint_from_script_function MARKER**"
    call s:throw_error()
  catch
    let l:throwpoint = v:throwpoint
  endtry
  let l:frames = strager#exception#parse_throwpoint(l:throwpoint)
  let [l:throw_frame, l:test_frame; _] = l:frames

  call assert_equal(
    \ "\x80\xfdR".s:sid().'_throw_error',
    \ l:throw_frame.function.real_name,
  \ )
  call assert_equal(s:script_path, l:throw_frame.script_path)
  call assert_equal(
    \ s:test_marker_line_number('s:throw_error'),
    \ l:throw_frame.line,
  \ )

  call assert_equal(
    \ 'Test_parse_throwpoint_from_script_function',
    \ l:test_frame.function.real_name,
  \ )
  call assert_equal(s:script_path, l:test_frame.script_path)
  call assert_equal(
    \ s:test_marker_line_number('Test_parse_throwpoint_from_script_function'),
    \ l:test_frame.line,
  \ )
endfunction

function! Test_parse_throwpoint_from_script_function_via_funcref()
  let l:throwpoint = v:none
  try
    " **MARKER Test_parse_throwpoint_from_script_function_via_funcref MARKER**"
    call s:call_throw_error_via_funcref()
  catch
    let l:throwpoint = v:throwpoint
  endtry
  let l:frames = strager#exception#parse_throwpoint(l:throwpoint)
  let [l:throw_frame, l:call_frame, l:test_frame; _] = l:frames

  call assert_equal(
    \ "\x80\xfdR".s:sid().'_throw_error',
    \ l:throw_frame.function.real_name,
  \ )
  call assert_equal(s:script_path, l:throw_frame.script_path)
  call assert_equal(
    \ s:test_marker_line_number('s:throw_error'),
    \ l:throw_frame.line,
  \ )

  call assert_equal(
    \ "\x80\xfdR".s:sid().'_call_throw_error_via_funcref',
    \ l:call_frame.function.real_name,
  \ )
  call assert_equal(s:script_path, l:call_frame.script_path)
  call assert_equal(
    \ s:test_marker_line_number('s:call_throw_error_via_funcref'),
    \ l:call_frame.line,
  \ )

  call assert_equal(
    \ 'Test_parse_throwpoint_from_script_function_via_funcref',
    \ l:test_frame.function.real_name,
  \ )
  call assert_equal(s:script_path, l:test_frame.script_path)
  call assert_equal(s:test_marker_line_number(
    \ 'Test_parse_throwpoint_from_script_function_via_funcref',
  \ ), l:test_frame.line)
endfunction

function! Test_format_throwpoint()
  let l:throwpoint = v:none
  try
    " **MARKER Test_format_throwpoint MARKER**"
    call s:call_throw_error_via_funcref()
  catch
    let l:throwpoint = v:throwpoint
  endtry
  let l:formatted = strager#exception#format_throwpoint(l:throwpoint)
  let [l:throw_line, l:call_line, l:test_line; _] = split(l:formatted, "\n")
  call assert_equal(
    \ s:script_path.':'.s:test_marker_line_number('s:throw_error')
      \ .':(s:throw_error):',
    \ l:throw_line,
  \ )
  call assert_equal(
    \ s:script_path.':'
      \ .s:test_marker_line_number('s:call_throw_error_via_funcref')
      \ .':(s:call_throw_error_via_funcref):',
    \ l:call_line,
  \ )
  call assert_equal(
    \ s:script_path.':'.s:test_marker_line_number('Test_format_throwpoint')
      \ .':(Test_format_throwpoint):',
    \ l:test_line,
  \ )
endfunction

function! s:call_throw_error_via_funcref()
  let l:Throw_error = funcref('s:throw_error')
  " **MARKER s:call_throw_error_via_funcref MARKER**
  call l:Throw_error()
endfunction

function! s:throw_error()
  " **MARKER s:throw_error MARKER**
  throw 'Some error'
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
