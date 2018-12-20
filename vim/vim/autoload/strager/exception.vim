" Example value of v:throwpoint:
" 'function strager#test#run_all_tests[12]..strager#test#run_tests[10]..Test_throwpoint_location, line 3'

function strager#exception#get_vim_error()
  return matchstr(v:exception, 'E.*$')
endfunction

function! strager#exception#format_throwpoint(throwpoint)
  let l:frames = strager#exception#parse_throwpoint(a:throwpoint)
  let l:lines = map(l:frames, {_, frame -> s:format_frame(frame)})
  return join(l:lines, "\n")
endfunction

function! s:format_frame(frame)
  if a:frame.script_path ==# v:none
    let l:output = printf(
      \ ':%s[%s]:',
      \ a:frame.autocommand.event,
      \ a:frame.autocommand.name,
    \ )
  else
    let l:output = a:frame.script_path.':'.a:frame.line.':'
  endif
  if type(a:frame.function) !=# v:t_none
    let l:output .= '('.a:frame.function.source_name.'):'
  endif
  return l:output
endfunction

function! strager#exception#parse_throwpoint(throwpoint)
  let l:match = matchlist(
    \ a:throwpoint,
    \ '^\%(function \(.*\)\|\(.\+\)\), line \([0-9]\+\)$',
  \ )
  if empty(l:match)
    return s:parse_autocommand_throwpoint(a:throwpoint)
  endif
  let [_, l:frames_string, l:script_path, l:throwing_function_line; _] = l:match
  let l:throwing_function_line = str2nr(l:throwing_function_line)
  if l:script_path ==# ''
    let l:frame_strings = split(l:frames_string, '\.\.')
    call reverse(l:frame_strings)
    let [l:throwing_function_name; l:calling_frame_strings] = l:frame_strings

    let l:frames = [s:frame(l:throwing_function_name, l:throwing_function_line)]
    for l:frame_string in l:calling_frame_strings
      call add(l:frames, s:parse_calling_frame(l:frame_string))
    endfor
    return l:frames
  else
    return [{
      \ 'autocommand': v:none,
      \ 'function': v:none,
      \ 'line': l:throwing_function_line,
      \ 'script_path': l:script_path,
    \ }]
  endif
endfunction

function! s:parse_autocommand_throwpoint(throwpoint)
  let l:match = matchlist(
    \ a:throwpoint,
    \ '^\([A-Za-z]\+\) Autocommands for "\(.*\)"$'
  \ )
  if empty(l:match)
    throw 'Not a valid throwpoint: '.string(a:throwpoint)
  endif
  let [_, l:event, l:name; _] = l:match
  return [{
    \ 'autocommand': {'event': l:event, 'name': l:name},
    \ 'function': v:none,
    \ 'line': v:none,
    \ 'script_path': v:none,
  \ }]
endfunction

" Example value of a:frame_string:
" 'strager#test#run_all_tests[12]'
function! s:parse_calling_frame(frame_string)
  let l:match = matchlist(a:frame_string, '^\(.*\)\[\(\d\+\)\]$')
  if empty(l:match)
    throw 'Not a valid throwpoint frame: '.string(a:frame_string)
  endif
  let [_, l:function_name, l:function_line; _] = l:match
  return s:frame(l:function_name, str2nr(l:function_line))
endfunction

function! s:frame(function_name, function_line)
  let l:loc = strager#function#function_source_location(a:function_name)
  return {
    \ 'autocommand': v:none,
    \ 'function': l:loc,
    \ 'line': l:loc.line + a:function_line,
    \ 'script_path': l:loc.script_path,
  \ }
endfunction
