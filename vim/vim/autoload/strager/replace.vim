function! strager#replace#prompt_replace_current_word() abort
  let l:current_word = expand('<cword>')
  " @@@ replacement escaping needs more extensive testing. put in strager#pattern#.
  call strager#replace#prompt_replace_pattern(printf(
    \ '\V\<%s\>',
    \ strager#pattern#escape_vnm(l:current_word),
  \ ), escape(l:current_word, '\'))
endfunction

function! strager#replace#prompt_replace_visual_selection() abort
  let l:selected_text = s:get_visual_selection()
  echomsg string({'selected_text': l:selected_text})

  " @@@ need to escape, holmes
  call strager#replace#prompt_replace_pattern(l:selected_text, l:selected_text)
endfunction

function! strager#replace#prompt_replace_pattern(pattern_to_replace, default_replacement)
  let l:pattern_separator = '/'
  " @@@ are these escapes correct? What if we end up with something like: \/ -> \\/
  let l:find_pattern = escape(a:pattern_to_replace, l:pattern_separator)
  let l:replacement = escape(a:default_replacement, l:pattern_separator)
  call feedkeys(join([
    \ ':%s',
    \ l:pattern_separator,
    \ l:find_pattern,
    \ l:pattern_separator,
    \ l:replacement,
    \ l:pattern_separator,
    \ 'g',
    \ "\<Left>\<Left>",
  \ ], ''), 'it')
endfunction

function! s:get_visual_selection() abort
    let [_, l:start_line_number, l:start_column, _] = getpos("'<")
    let [_, l:end_line_number, l:end_column, _] = getpos("'>")
    if l:start_line_number !=# l:end_line_number
      echoerr '@@@ only one line is supported'
    endif
    if l:end_column < l:start_column
      let [l:start_column, l:end_column] = [l:end_column, l:start_column]
    end
    let l:line = getline(l:start_line_number)
    return l:line[l:start_column - 1 : l:end_column - 1]
endfunction

" @@@ todo:
" * Avoid moving cursor (incsearch) -- probably jarring
