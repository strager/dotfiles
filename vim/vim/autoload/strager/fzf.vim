function! strager#fzf#header_lines(fzf_run_options)
  let l:options = s:parse_command_line_options(a:fzf_run_options.options)
  let l:header_lines = []
  if l:options.header !=# v:none
    call add(l:header_lines, l:options.header)
  endif
  if l:options.header_lines > 0
    let l:temp_lines = a:fzf_run_options.source[: l:options.header_lines - 1]
    call s:transform_lines(l:temp_lines, l:options.delimiter, l:options.with_nth)
    call extend(l:header_lines, l:temp_lines)
  endif
  return l:header_lines
endfunction

function! strager#fzf#input_lines(fzf_run_options)
  let l:source = get(a:fzf_run_options, 'source', v:none)
  if type(l:source) ==# v:t_none
    let l:source = s:default_command()
  endif
  if type(l:source) ==# v:t_string
    let l:output = system(l:source)
    if v:shell_error != 0
      throw printf(
        \ 'ES014: Command failed with exit code %d: %s',
        \ v:shell_error,
        \ l:source,
      \ )
    endif
    return split(l:output, "\n")
  endif
  return l:source
endfunction

function! s:default_command()
  let l:command = $FZF_DEFAULT_COMMAND
  if l:command !=# ''
    return l:command
  endif

  " NOTE(strager): This file is specific to my dotfiles setup. fzf would not
  " read this file.
  let l:command_file_path = fnamemodify(
    \ '~/.config/fzf/FZF_DEFAULT_COMMAND',
    \ ':p',
  \ )
  try
    let l:command_file_lines = readfile(l:command_file_path)
  catch /E484:/
    " The file does not exist. Ignore this error and fall through.
    let l:command_file_lines = []
  endtry
  if !empty(l:command_file_lines)
    let l:command = l:command_file_lines[0]
    if l:command !=# ''
      return l:command
    endif
  endif

  throw 'Expected FZF_DEFAULT_COMMAND to be set'
endfunction

function! strager#fzf#presented_lines(fzf_run_options)
  let l:options = s:parse_command_line_options(a:fzf_run_options.options)
  let l:lines = strager#fzf#input_lines(
    \ a:fzf_run_options
  \ )[l:options.header_lines :]
  call s:transform_lines(l:lines, l:options.delimiter, l:options.with_nth)
  return l:lines
endfunction

function! strager#fzf#prompt(fzf_run_options)
  let l:options = s:parse_command_line_options(a:fzf_run_options.options)
  return l:options.prompt
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

function! s:transform_lines(lines, field_delimiter, field_index_expressions)
  call map(a:lines, {_, line -> s:transform_line(
    \ line,
    \ a:field_delimiter,
    \ a:field_index_expressions,
  \ )})
endfunction

function! s:transform_line(line, field_delimiter, field_index_expressions)
  if type(a:field_delimiter) ==# v:t_none
    throw 'ES012: Default field delimiter is not supported'
  endif
  let l:split_pattern = printf('\C\V%s\zs', strager#pattern#escape_vnm(a:field_delimiter))
  let l:fields = split(a:line, l:split_pattern)
  let l:output_pieces = []
  for [l:begin, l:end] in a:field_index_expressions
    if type(l:begin) == v:t_none
      let l:begin_index = 0
    else
      let l:begin_index = l:begin - 1
    endif
    if type(l:end) == v:t_none
      let l:end_index = -1
    else
      let l:end_index = l:end - 1
    endif
    call extend(l:output_pieces, l:fields[l:begin_index : l:end_index])
  endfor
  return join(l:output_pieces, '')
endfunction

function! s:parse_command_line_options(options)
  let l:result = {
    \ 'delimiter': v:none,
    \ 'header': v:none,
    \ 'header_lines': 0,
    \ 'prompt': '> ',
    \ 'with_nth': [[v:none, v:none]],
  \ }
  for l:option in a:options
    let l:match = matchlist(l:option, '--delimiter=\(.*\)')
    if l:match !=# []
      let [l:_, l:result.delimiter; l:_] = l:match
    endif
    let l:match = matchstr(l:option, '--header-lines=\zs\d\+\ze')
    if l:match !=# ''
      let l:result.header_lines = str2nr(l:match)
    endif
    let l:match = matchlist(l:option, '--header=\(.*\)')
    if l:match !=# []
      let [l:_, l:result.header; l:_] = l:match
    endif
    let l:match = matchlist(l:option, '--prompt=\(.*\)')
    if l:match !=# []
      let [l:_, l:result.prompt; l:_] = l:match
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
  let l:range = s:parse_command_line_field_index_expression_raw(a:expressions)
  if (type(l:range[0]) !=# v:t_none && l:range[0] == 0)
    \ || (type(l:range[1]) !=# v:t_none && l:range[1] == 0)
    throw printf('ES011: Invalid field index expression: %s', a:expressions)
  endif
  return [l:range]
endfunction

function! s:parse_command_line_field_index_expression_raw(expression)
  let l:match = matchstr(a:expression, '^\d\+$')
  if l:match !=# ''
    let l:field_index = str2nr(l:match)
    return [l:field_index, l:field_index]
  endif

  let l:match = matchlist(a:expression, '^\(\d\+\)\.\.$')
  if l:match !=# []
    let [l:_, l:field_index_str; l:_] = l:match
    let l:field_index = str2nr(l:field_index_str)
    return [l:field_index, v:none]
  endif

  let l:match = matchlist(a:expression, '^\.\.\(\d\+\)$')
  if l:match !=# []
    let [l:_, l:field_index_str; l:_] = l:match
    let l:field_index = str2nr(l:field_index_str)
    return [v:none, l:field_index]
  endif

  " TODO(strager): Support BEGIN..END ranges.
  " TODO(strager): Support comma-separated field ranges.
  " TODO(strager): Support negative field numbers.
  throw printf(
    \ 'ES009: Field index expression not implemented: %s',
    \ a:expression,
  \ )
endfunction
