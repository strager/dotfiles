function! strager#identifier#parse(identifier) abort
  let l:s = a:identifier
  let l:is_snake = v:false
  let l:is_camel = v:false
  let l:parts = []

  let [l:prefix, l:_prefix_begin, l:prefix_end] = matchstrpos(l:s, '\v^_*')
  call add(l:parts, l:prefix)
  let l:s = l:s[l:prefix_end :]

  let [l:suffix, l:suffix_begin, l:_suffix_end] = matchstrpos(l:s, '\v_*$')
  let l:s = l:s[: l:suffix_begin-1]

  while v:true
    let [l:match, l:word_end, l:next_word] 
      \ = matchstrpos(l:s, '\v_+|\U\zs\ze\u')
    if l:next_word ==# -1
      break
    endif
    if l:match[0] ==# '_'
      let l:is_snake = v:true
    else
      let l:is_camel = v:true
    endif
    call add(l:parts, l:s[0 : l:word_end-1])
    let l:s = l:s[l:next_word :]
  endwhile
  if l:s !=# ''
    call add(l:parts, l:s)
  endif
  call add(l:parts, l:suffix)

  if len(l:parts) ==# 3
    let l:style = s:get_part_style(l:parts[1])
  else
    let l:has_later = {
      \ 'lower': v:false,
      \ 'shout': v:false,
      \ 'upper': v:false,
      \ 'unknown': v:false,
    \ }
    for l:part in l:parts[2 : -2]
      let l:has_later[s:get_part_style(l:part)] = v:true
    endfor
    let l:first_style = s:get_part_style(l:parts[1])
    if l:is_camel && l:is_snake
      let l:style = 'unknown'
    elseif l:has_later.lower && (l:has_later.shout || l:has_later.upper)
      let l:style = 'unknown'
    elseif l:is_snake && l:first_style ==# 'lower' && (l:has_later.shout || l:has_later.upper)
      let l:style = 'unknown'
    elseif l:is_snake && l:first_style ==# 'shout' && !l:has_later.lower && !l:has_later.upper
      let l:style = 'shout_snake'
    elseif l:is_snake && (l:first_style ==# 'upper' || l:first_style ==# 'shout') && !l:has_later.upper
      let l:style = 'title_snake'
    elseif l:is_snake && l:first_style ==# 'shout' && l:has_later.upper && !l:has_later.shout
      let l:style = 'upper_snake'
    elseif l:is_snake
      let l:style = l:first_style . '_snake'
    elseif l:is_camel
      let l:style = l:first_style . '_camel'
    else
      let l:style = 'unknown'
    endif
  endif

  return {
    \ 'style': l:style,
    \ 'parts': l:parts,
  \ }
endfunction

function! s:get_part_style(s) abort
  if a:s =~# '\v^\l'
    return 'lower'
  elseif a:s =~# '\v\u'
    if a:s !~# '\v\l'
      return 'shout'
    else
      return 'upper'
    endif
  else
    return 'unknown'
  endif
endfunction

function! strager#identifier#reformat(parts, new_style) abort
  let l:first_style = {
    \ 'lower': 'lower',
    \ 'upper': 'upper',
    \ 'shout': 'shout',
    \ 'lower_camel': 'lower',
    \ 'upper_camel': 'upper',
    \ 'lower_snake': 'lower',
    \ 'upper_snake': 'upper',
    \ 'title_snake': 'upper',
    \ 'shout_snake': 'shout',
  \ }[a:new_style]
  let l:result = a:parts[0]
  if len(a:parts) > 2
    let l:new_inner_parts = [s:transform_part(a:parts[1], l:first_style)]
    let l:separator = ''
    if len(a:parts) > 3
      let l:separator = {
        \ 'lower_camel': '',
        \ 'upper_camel': '',
        \ 'lower_snake': '_',
        \ 'upper_snake': '_',
        \ 'title_snake': '_',
        \ 'shout_snake': '_',
      \ }[a:new_style]
      let l:rest_style = {
        \ 'lower_camel': 'upper',
        \ 'upper_camel': 'upper',
        \ 'lower_snake': 'lower',
        \ 'upper_snake': 'upper',
        \ 'title_snake': 'lower',
        \ 'shout_snake': 'shout',
      \ }[a:new_style]
      for l:part in a:parts[2 : -2]
        call add(l:new_inner_parts, s:transform_part(l:part, l:rest_style))
      endfor
    endif
    let l:result .= join(l:new_inner_parts, l:separator)
  endif
  let l:result .= a:parts[-1]
  return l:result
endfunction

function! s:transform_part(part, style)
  if a:style ==# 'upper'
    return toupper(a:part[0]) . tolower(a:part[1 :])
  elseif a:style ==# 'lower'
    return tolower(a:part)
  elseif a:style ==# 'shout'
    return toupper(a:part)
  endif
  throw 'Invalid transform style: '.a:style
endfunction

function! strager#identifier#cycle_format(identifier, style_map) abort
  let l:parsed = strager#identifier#parse(a:identifier)
  let l:new_style = get(a:style_map, l:parsed.style, v:null)
  if l:new_style ==# v:null
    let l:new_style = a:style_map['unknown']
  endif
  return strager#identifier#reformat(l:parsed.parts, l:new_style)
endfunction

function! strager#identifier#cycle_format_under_cursor(style_map) abort
  let l:new_identifier = strager#identifier#cycle_format(expand('<cword>'), a:style_map)
  let l:old_register = @-
  try
    let @- = l:new_identifier
    normal! viw"-P
  finally
    let @- = l:old_register
  endtry
endfunction
