function! strager#fzf#header_lines(fzf_run_options)
  let l:options = s:parse_command_line_options(a:fzf_run_options.options)
  let l:header_lines = []
  if l:options.header !=# v:none
    call add(l:header_lines, l:options.header)
  endif
  if l:options.header_lines > 0
    let l:temp_lines = a:fzf_run_options.source[: l:options.header_lines - 1]
    call s:transform_lines(l:temp_lines, l:options.with_nth)
    call extend(l:header_lines, l:temp_lines)
  endif
  return l:header_lines
endfunction

function! strager#fzf#input_lines(fzf_run_options)
  return a:fzf_run_options.source
endfunction

function! strager#fzf#presented_lines(fzf_run_options)
  let l:options = s:parse_command_line_options(a:fzf_run_options.options)
  let l:lines = strager#fzf#input_lines(
    \ a:fzf_run_options
  \ )[l:options.header_lines :]
  call s:transform_lines(l:lines, l:options.with_nth)
  return l:lines
endfunction

function! strager#fzf#call_sink(fzf_run_options, selected_lines)
  let l:sink = get(a:fzf_run_options, 'sink', v:none)
  if type(l:sink) !=# v:t_none
    throw 'ES007: Plain sink is not supported'
  endif
  let l:Sink_star = get(a:fzf_run_options, 'sink*', v:none)
  if type(l:Sink_star) !=# v:t_func
    throw 'ES008: Missing sink*'
  endif

  call l:Sink_star(a:selected_lines)
endfunction

function! s:transform_lines(lines, field_index_expressions)
  call map(
    \ a:lines,
    \ {_, line -> s:transform_line(line, a:field_index_expressions)},
  \ )
endfunction

" TODO(strager): Split according to --delimiter.
function! s:transform_line(line, field_index_expressions)
  let l:fields = split(a:line, ' ')
  let l:output_pieces = []
  for [l:begin, l:end] in a:field_index_expressions
    call extend(l:output_pieces, l:fields[l:begin - 1:l:end - 1])
  endfor
  return join(l:output_pieces, ' ')
endfunction

function! s:parse_command_line_options(options)
  let l:result = {
    \ 'header': v:none,
    \ 'header_lines': 0,
    \ 'with_nth': [[v:none, v:none]],
  \ }
  for l:option in a:options
    let l:match = matchstr(l:option, '--header-lines=\zs\d\+\ze')
    if l:match !=# ''
      let l:result.header_lines = str2nr(l:match)
    endif
    let l:match = matchlist(l:option, '--header=\(.*\)')
    if l:match !=# []
      let [l:_, l:result.header; l:_] = l:match
    endif
    let l:match = matchlist(l:option, '--with-nth=\(.*\)')
    if l:match !=# []
      let [l:_, l:with_nth_str; l:_] = l:match
      let l:result.with_nth = s:parse_command_line_field_index_expressions(
        \ l:with_nth_str,
      \ )
    endif
  endfor
  return l:result
endfunction

function! s:parse_command_line_field_index_expressions(expressions)
  if a:expressions !~# '^\d\+$'
    throw printf(
      \ 'ES009: Field index expression not implemented: %s',
      \ a:expressions,
    \ )
  endif
  let l:field_index = str2nr(a:expressions)
  if l:field_index == 0
    throw printf('ES011: Invalid field index expression: %s', a:expressions)
  endif
  return [[l:field_index, l:field_index]]
endfunction
