function strager#check_syntax#check_syntax_and_exit()
  let l:issues = s:get_syntax_issues_for_current_window()
  if l:issues ==# []
    qall!
  else
    cquit!
  endif
endfunction

function strager#check_syntax#check_syntax()
  let l:issues = s:get_syntax_issues_for_current_window()
  let l:buffer_number = bufnr('%')
  let l:quickfix_entries = []
  for l:issue in l:issues
    let l:entry = strager#check_syntax_internal#get_quickfix_item_for_issue(
      \ l:issue,
    \ )
    let l:entry.bufnr = l:buffer_number
    call add(l:quickfix_entries, l:entry)
  endfor
  call setqflist(l:quickfix_entries)
  if l:quickfix_entries !=# []
    cc
  endif
endfunction

function s:get_syntax_issues_for_current_window()
  let l:issues = []
  let l:buffer_lines = strager#buffer#get_current_buffer_lines()
  let l:checks = strager#check_syntax_internal#parse_syntax_checks(
    \ l:buffer_lines,
  \ )
  if l:checks ==# []
    call add(l:issues, {'text': 'Missing checks'})
  endif
  let l:aliases = strager#check_syntax_internal#parse_syntax_aliases(
    \ l:buffer_lines,
    \ l:issues,
  \ )
  call strager#check_syntax#check_syntax_generic({
    \ 'aliases': l:aliases,
    \ 'checks': l:checks,
    \ 'get_syntax_item': {line, column ->
      \ strager#check_syntax_internal#syntax_item_from_current_window(
        \ line,
        \ column,
      \ )
    \ },
  \ }, l:issues)
  return l:issues
endfunction

function strager#check_syntax#check_syntax_generic(options, out_issues)
  let l:aliases = a:options.aliases
  let l:checks = a:options.checks
  let l:Get_syntax_item = a:options.get_syntax_item
  for l:check in l:checks
    for l:column_index in range(len(l:check.check_string))
      let l:check_char = l:check.check_string[l:column_index]
      if l:check_char ==# ' '
        continue
      endif
      let l:column_number = l:column_index + 1
      let l:line_number = l:check.line
      if !has_key(l:aliases, l:check_char)
        call add(a:out_issues, {
          \ 'column': l:column_number,
          \ 'line': l:line_number,
          \ 'text': printf('Unspecified alias code: %s', l:check_char),
        \ })
        continue
      endif
      let l:expected_syntax_items = l:aliases[l:check_char]
      if type(l:expected_syntax_items) ==# v:t_none
        continue
      endif
      let l:actual_syntax_item = l:Get_syntax_item(
        \ l:line_number,
        \ l:column_number,
      \ )
      if index(l:expected_syntax_items, l:actual_syntax_item) ==# -1
        call add(a:out_issues, {
          \ 'column': l:column_number,
          \ 'line': l:line_number,
          \ 'text': printf(
            \ 'Expected %s but got %s',
            \ s:format_syntax_items(l:expected_syntax_items),
            \ s:format_syntax_item(l:actual_syntax_item),
          \ ),
        \ })
      endif
    endfor
  endfor
endfunction

function s:format_syntax_items(syntax_item_names)
  let l:names = map(copy(a:syntax_item_names), {_, name ->
    \ s:format_syntax_item(name)
  \ })
  return join(l:names, ' or ')
endfunction

function s:format_syntax_item(syntax_item_name)
  if a:syntax_item_name ==# v:none
    return '<none>'
  else
    return a:syntax_item_name
  endif
endfunction
