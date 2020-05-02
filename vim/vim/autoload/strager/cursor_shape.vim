let s:insert_cursor_shape = 'block'
let s:normal_cursor_shape = 'block'
let s:replace_cursor_shape = 'block'

function! strager#cursor_shape#set_cursor_shapes(shapes_by_mode) abort
  let s:insert_cursor_shape = a:shapes_by_mode.insert
  let s:normal_cursor_shape = a:shapes_by_mode.normal
  let s:replace_cursor_shape = a:shapes_by_mode.replace
  call s:update_cursor_shapes_now()
  augroup strager_cursor_shape
    autocmd!
    autocmd TermChanged * call s:update_cursor_shapes_now()
    autocmd VimEnter * call s:update_cursor_shapes_now()
  augroup END
endfunction

function! s:update_cursor_shapes_now() abort
  let &t_EI = s:cursor_shape_code(s:normal_cursor_shape)
  let &t_SI = s:cursor_shape_code(s:insert_cursor_shape)
  let &t_SR = s:cursor_shape_code(s:replace_cursor_shape)
  let &t_ve = ''
  let &t_vi = ''
  let &t_vs = ''
endfunction

function! s:cursor_shape_code(shape) abort
  if has('unix')
    return s:iterm_cursor_shape_code(a:shape).s:linux_cursor_shape_code(a:shape)
  else
    return ''
  endif
endfunction

function! s:iterm_cursor_shape_code(shape) abort
  return printf(
    \ "\<Esc>]1337;CursorShape=%d\x7",
    \ s:iterm_cursor_shape_id(a:shape),
  \ )
endfunction

function! s:iterm_cursor_shape_id(shape) abort
  if a:shape ==# 'block'
    return 0
  elseif a:shape ==# 'vertical bar'
    return 1
  elseif a:shape ==# 'underline'
    return 2
  else
    throw printf('ES006: Unsupported cursor shape: %s', a:shape)
  endif
endfunction

function! s:linux_cursor_shape_code(shape) abort
  return printf(
    \ "\<Esc>[?%d;0;0;c",
    \ s:linux_cursor_shape_id(a:shape),
  \ )
endfunction

function! s:linux_cursor_shape_id(shape) abort
  if a:shape ==# 'block'
    return 6
  elseif a:shape ==# 'vertical bar'
    return 3
  elseif a:shape ==# 'underline'
    return 1
  else
    throw printf('ES006: Unsupported cursor shape: %s', a:shape)
  endif
endfunction
