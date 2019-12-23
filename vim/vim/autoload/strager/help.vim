function! strager#help#open_help_tag(tag) abort
  let l:window_id = win_getid()
  execute printf('tab help %s', a:tag)
  let l:help_tab_number = tabpagenr()
  try
    let [l:_bufnum, l:help_line_number, l:help_column_number, l:help_offset, l:_curswant] = getcurpos()
    let l:help_buffer_number = bufnr('%')
    call win_gotoid(l:window_id)
    execute printf('buffer %d', l:help_buffer_number)
    call setpos('.', [
      \ v:none,
      \ l:help_line_number,
      \ l:help_column_number,
      \ l:help_offset,
    \ ])
  finally
    execute printf('tabclose %d', l:help_tab_number)
  endtry
endfunction

function! strager#help#register_command(options)
  let l:bang = ''
  if a:options['force']
    let l:bang = '!'
  endif
  exec printf(
    \ 'command%s -complete=help -nargs=1 Help %s',
    \ l:bang,
    \ 'call strager#help#open_help_tag(<q-args>)',
  \ )
endfunction
