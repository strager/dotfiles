" Example value of v:throwpoint:
" 'function strager#test#run_all_tests[12]..strager#test#run_tests[10]..Test_throwpoint_location, line 3'

function! strager#exception#get_vim_error() abort
  return matchstr(v:exception, 'E.*$')
endfunction

function! strager#exception#dump_stack_trace() abort
  try
    throw 'dump'
  catch /dump/
    for l:line in split(strager#exception#format_throwpoint(v:throwpoint), '\n')
      echomsg l:line
    endfor
  endtry
endfunction

function! strager#exception#format_throwpoint(throwpoint) abort
  let l:frames = strager#exception#parse_throwpoint(a:throwpoint)
  let l:lines = map(l:frames, {_, frame -> s:format_frame(frame)})
  return join(l:lines, "\n")
endfunction

function! s:format_frame(frame) abort
  if a:frame.script_path !=# v:null
    let l:output = a:frame.script_path.':'.a:frame.line.':'
  elseif !(a:frame.autocommand is v:null)
    let l:output = printf(
      \ ':%s[%s]:',
      \ a:frame.autocommand.event,
      \ a:frame.autocommand.name,
    \ )
  else
    let l:output = '::'
  endif
  if !(a:frame.function is v:null)
    if strager#function#is_lambda_function_name(a:frame.function.real_name)
      let l:output .= '(lambda):'
    else
      let l:output .= '('.a:frame.function.source_name.'):'
    endif
  endif
  return l:output
endfunction

function! strager#exception#parse_throwpoint(throwpoint) abort
  let l:frame_strings = split(a:throwpoint, '\.\.')
  call reverse(l:frame_strings)

  let l:frames = []
  for l:frame_string in l:frame_strings
    call add(l:frames, s:parse_frame(l:frame_string))
  endfor
  return l:frames
endfunction

" Example value of a:frame_string:
" 'strager#test#run_all_tests[12]'
" 'strager#test#run_all_tests, line 12'
" 'function strager#test#run_all_tests[12]'
" 'command line'
" 'script /path/to/file.vim[123]'
" 'User Autocommands for "test_parse_throwpoint_from_autocmd"'
function! s:parse_frame(frame_string) abort
  if a:frame_string ==# 'command line'
    return {
      \ 'autocommand': v:null,
      \ 'function': v:null,
      \ 'line': v:null,
      \ 'script_path': '<command line>',
    \ }
  endif

  let l:match = matchlist(a:frame_string, '^script \(.*\)\[\(\d\+\)\]$')
  if !empty(l:match)
    let [_, l:script_path, l:line; _] = l:match
    return {
      \ 'autocommand': v:null,
      \ 'function': v:null,
      \ 'line': str2nr(l:line),
      \ 'script_path': l:script_path,
    \ }
  endif

  let l:match = matchlist(a:frame_string, '^script \(.*\), line \(\d\+\)$')
  if !empty(l:match)
    let [_, l:script_path, l:line; _] = l:match
    return {
      \ 'autocommand': v:null,
      \ 'function': v:null,
      \ 'line': str2nr(l:line),
      \ 'script_path': l:script_path,
    \ }
  endif

  let l:match = matchlist(a:frame_string, '^\([A-Za-z]\+\) Autocommands for "\(.*\)"$')
  if !empty(l:match)
    let [_, l:event, l:name; _] = l:match
    return {
      \ 'autocommand': {'event': l:event, 'name': l:name},
      \ 'function': v:null,
      \ 'line': v:null,
      \ 'script_path': v:null,
    \ }
  endif

  let l:match = matchlist(a:frame_string, '^\%(function \)\?\(.*\)\[\(\d\+\)\]$')
  if !empty(l:match)
    let [_, l:function_name, l:function_line; _] = l:match
    return s:frame(l:function_name, str2nr(l:function_line))
  endif

  let l:match = matchlist(a:frame_string, '^\%(function \)\?\(.*\), line \(\d\+\)$')
  if !empty(l:match)
    let [_, l:function_name, l:function_line; _] = l:match
    return s:frame(l:function_name, str2nr(l:function_line))
  endif

  throw 'Not a valid throwpoint frame: '.string(a:frame_string)
endfunction

function! s:frame(function_name, function_line) abort
  let l:loc = strager#function#function_source_location(a:function_name)
  let l:line = v:null
  if !(l:loc.line is v:null)
    let l:line = l:loc.line + a:function_line
    if strager#function#is_lambda_function_name(a:function_name)
      let l:line -= 1
    endif
  endif
  return {
    \ 'autocommand': v:null,
    \ 'function': l:loc,
    \ 'line': l:line,
    \ 'script_path': l:loc.script_path,
  \ }
endfunction
