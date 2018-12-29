let s:insert_cursor_shape = 'block'
let s:normal_cursor_shape = 'block'
let s:replace_cursor_shape = 'block'

function! strager#cursor_shape#set_cursor_shapes(shapes_by_mode)
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

function! s:update_cursor_shapes_now()
  let &t_EI = s:iterm_cursor_shape_code(s:normal_cursor_shape)
  let &t_SI = s:iterm_cursor_shape_code(s:insert_cursor_shape)
  let &t_SR = s:iterm_cursor_shape_code(s:replace_cursor_shape)
endfunction

function! s:iterm_cursor_shape_code(shape)
  return printf(
    \ "\<Esc>]1337;CursorShape=%d\x7",
    \ s:iterm_cursor_shape_id(a:shape),
  \ )
endfunction

function! s:iterm_cursor_shape_id(shape)
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
