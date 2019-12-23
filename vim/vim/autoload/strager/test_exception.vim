let s:script_path = expand('<sfile>:p')

function! Test_parse_throwpoint_from_user_function() abort
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
  call assert_equal(v:none, l:throw_frame.autocommand)
endfunction

function! Test_parse_throwpoint_from_built_in_function() abort
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
  call assert_equal(v:none, l:throw_frame.autocommand)
endfunction

function! Test_parse_throwpoint_through_built_in_function() abort
  let l:throwpoint = v:none
  let l:function = [function('<SNR>'.s:sid().'_throw_error')]
  try
    " **MARKER Test_parse_throwpoint_through_built_in_function caller MARKER**
    call map([1], l:function[0])
  catch
    let l:throwpoint = v:throwpoint
  endtry
  let l:frames = strager#exception#parse_throwpoint(l:throwpoint)
  let [l:throw_frame, l:call_frame; _] = l:frames

  call assert_equal(
    \ "\x80\xfdR".s:sid().'_throw_error',
    \ l:throw_frame.function.real_name,
  \ )
  call assert_equal(s:script_path, l:throw_frame.script_path)
  call assert_equal(s:test_marker_line_number(
    \ 's:throw_error',
  \ ), l:throw_frame.line)

  call assert_equal(
    \ 'Test_parse_throwpoint_through_built_in_function',
    \ l:call_frame.function.real_name,
    \ 'map() should not have its own frame',
  \ )
  call assert_equal(s:test_marker_line_number(
    \ 'Test_parse_throwpoint_through_built_in_function caller',
  \ ), l:call_frame.line)
endfunction

function! Test_parse_throwpoint_from_live_lambda() abort
  let l:throwpoint = v:none
  " **MARKER Test_parse_throwpoint_from_lambda MARKER**"
  let l:lambda = [{-> undefined_name}]
  try
    call l:lambda[0]()
  catch
    let l:throwpoint = v:throwpoint
  endtry
  let l:frames = strager#exception#parse_throwpoint(l:throwpoint)
  let [l:throw_frame; _] = l:frames

  call assert_equal(
    \ v:none,
    \ l:throw_frame.function.source_name,
    \ 'Lambda frames should not have a name',
  \ )
  call assert_equal(s:script_path, l:throw_frame.script_path)
  call assert_equal(s:test_marker_line_number(
    \ 'Test_parse_throwpoint_from_lambda',
  \ ), l:throw_frame.line)
endfunction

function! Test_parse_throwpoint_from_dead_lambda() abort
  let l:throwpoint = v:none
  let l:lambda = [{-> undefined_name}]
  try
    call l:lambda[0]()
  catch
    let l:throwpoint = v:throwpoint
  endtry
  let l:lambda[0] = v:none
  " The lambda function should now be undefined.
  let l:frames = strager#exception#parse_throwpoint(l:throwpoint)
  let [l:throw_frame; _] = l:frames

  call assert_equal(
    \ v:none,
    \ l:throw_frame.function.source_name,
    \ 'Lambda frame should not have a name',
  \ )
  call assert_equal(
    \ v:none,
    \ l:throw_frame.script_path,
    \ 'Lambda frame should not have a source location',
  \ )
  call assert_equal(
    \ v:none,
    \ l:throw_frame.line,
    \ 'Lambda frame should not have a source location',
  \ )
endfunction

function! Test_parse_throwpoint_from_script_function() abort
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

function! Test_parse_throwpoint_from_script_function_via_funcref() abort
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

function! Test_parse_throwpoint_from_script_body() abort
  let l:test_script_path = strager#path#join([fnamemodify(s:script_path, ':h'), 'test_exception_helper.vim'])
  let l:throwpoint = v:none
  try
    execute 'source '.fnameescape(l:test_script_path)
  catch
    let l:throwpoint = v:throwpoint
  endtry
  let l:frames = strager#exception#parse_throwpoint(l:throwpoint)
  let [l:throw_frame; _] = l:frames

  call assert_equal(v:none, l:throw_frame.function)
  call assert_equal(l:test_script_path, l:throw_frame.script_path)
  call assert_equal(1, l:throw_frame.line)
  call assert_equal(v:none, l:throw_frame.autocommand)
endfunction

function! Test_parse_throwpoint_from_autocmd() abort
  augroup test_parse_throwpoint_from_autocmd_group
    autocmd!
    autocmd User test_parse_throwpoint_from_autocmd throw 'My error'
  augroup END

  let l:throwpoint = v:none
  try
    doautocmd User test_parse_throwpoint_from_autocmd
  catch
    let l:throwpoint = v:throwpoint
  endtry
  let l:frames = strager#exception#parse_throwpoint(l:throwpoint)
  let [l:throw_frame; _] = l:frames

  call assert_equal(v:none, l:throw_frame.function)
  call assert_equal(v:none, l:throw_frame.script_path)
  call assert_equal(v:none, l:throw_frame.line)
  call assert_equal("User", l:throw_frame.autocommand.event)
  call assert_equal(
    \ "test_parse_throwpoint_from_autocmd",
    \ l:throw_frame.autocommand.name,
  \ )
endfunction

function! Test_format_throwpoint() abort
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

function! Test_format_script_throwpoint() abort
  let l:throwpoint = '/myscript.vim, line 42'
  call assert_equal(
    \ '/myscript.vim:42:',
    \ strager#exception#format_throwpoint(l:throwpoint),
  \ )
endfunction

function! Test_format_autocommand_throwpoint() abort
  let l:throwpoint = 'User Autocommands for "foo"'
  call assert_equal(
    \ ':User[foo]:',
    \ strager#exception#format_throwpoint(l:throwpoint),
  \ )
endfunction

function! Test_format_live_lamba_throwpoint() abort
  " **MARKER Test_format_live_lamba_throwpoint MARKER**"
  let l:lambda = [{-> 42}]
  let l:throwpoint = printf('function %s, line 1', get(l:lambda[0], 'name'))
  call assert_equal(
    \ printf(
      \ '%s:%d:(lambda):',
      \ s:script_path,
      \ s:test_marker_line_number('Test_format_live_lamba_throwpoint'),
    \ ),
    \ strager#exception#format_throwpoint(l:throwpoint),
  \ )
endfunction

function! Test_format_dead_lamba_throwpoint() abort
  let l:lambda = [{-> 42}]
  let l:throwpoint = printf('function %s, line 1', get(l:lambda[0], 'name'))
  let l:lambda[0] = v:none
  call assert_equal(
    \ '::(lambda):',
    \ strager#exception#format_throwpoint(l:throwpoint),
  \ )
endfunction

function! s:call_throw_error_via_funcref() abort
  let l:Throw_error = funcref('s:throw_error')
  " **MARKER s:call_throw_error_via_funcref MARKER**
  call l:Throw_error()
endfunction

function! s:throw_error(...) abort
  " **MARKER s:throw_error MARKER**
  throw 'Some error'
endfunction

function! s:sid() abort
  " See: :help <SID>
  return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_sid$')
endfun

function! s:test_marker_line_number(marker_name) abort
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
