function! strager#check_syntax_internal#parse_syntax_checks(lines) abort
  let l:checks = []
  for l:line_index in range(len(a:lines))
    let l:line = a:lines[l:line_index]
    let l:match = matchlist(l:line, '\(.*\):CHECK-NEXT-LINE')
    if l:match !=# []
      let [l:_, l:check_string; l:_] = l:match
      let l:next_line_number = l:line_index + 2
      call add(l:checks, {
        \ 'line': l:next_line_number,
        \ 'check_string': l:check_string,
      \ })
    endif
  endfor
  return l:checks
endfunction

function! strager#check_syntax_internal#parse_syntax_aliases(lines, out_issues) abort
  let l:aliases = {}
  for l:line_index in range(len(a:lines))
    let l:line = a:lines[l:line_index]
    let l:match = matchlist(l:line, '^\(.*CHECK-ALIAS:\)\(.*\)')
    if l:match ==# []
      continue
    endif
    let [l:_, l:prefix, l:arguments; l:_] = l:match
    let l:column_index = len(l:prefix)
    let l:match = matchlist(l:arguments, '^\s*\(\S\)\s\+\(\S\+\)')
    if l:match ==# []
      call add(a:out_issues, {
        \ 'line': l:line_index + 1,
        \ 'column': l:column_index + 1,
        \ 'text': 'Alias code is required',
      \ })
      continue
    endif
    let [l:_, l:alias, l:syntax_item_names_string; l:_] = l:match
    if l:syntax_item_names_string ==# '<ignore>'
      let l:syntax_item_names = v:null
    else
      let l:syntax_item_names = split(l:syntax_item_names_string, '|')
      call map(l:syntax_item_names, {_, name ->
        \ s:parse_check_alias_syntax_item_name(name)
      \ })
    endif
    let l:aliases[l:alias] = l:syntax_item_names
  endfor
  return l:aliases
endfunction

function! s:parse_check_alias_syntax_item_name(syntax_item_name) abort
  if a:syntax_item_name ==# '<none>'
    return v:null
  else
    return a:syntax_item_name
  endif
endfunction

function! strager#check_syntax_internal#get_quickfix_item_for_issue(issue) abort
  let l:item = {
    \ 'text': a:issue.text,
    \ 'type': 'E',
    \ 'vcol': v:false,
  \ }
  if has_key(a:issue, 'line')
    let l:item.lnum = a:issue.line
  endif
  if has_key(a:issue, 'column')
    let l:item.col = a:issue.column
  endif
  return l:item
endfunction

function! strager#check_syntax_internal#syntax_item_from_current_window(line, column) abort
  let l:syntax_item_ids = synstack(a:line, a:column)
  if l:syntax_item_ids ==# []
    return v:null
  endif
  return synIDattr(l:syntax_item_ids[-1], 'name', 'term')
endfunction
