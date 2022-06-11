function! strager#subvim#launch_vim_in_terminal() abort
  if has('nvim')
    execute printf(
      \ 'terminal %s -n',
      \ fnameescape(v:progpath),
    \ )
  else
    execute printf(
      \ 'terminal ++noclose ++rows=10 ++cols=80 %s -n',
      \ fnameescape(v:progpath),
    \ )
  endif
  return bufnr('%')
endfunction

function! strager#subvim#run_ex_command(terminal, ex_command) abort
  if has('nvim')
    " HACK(strager)
    sleep 100m
  endif
  call strager#subvim#send_keys(a:terminal, ':'.a:ex_command."\<CR>")
  sleep 100m
  if !has('nvim')
    call term_wait(a:terminal)
  endif
endfunction

if has('nvim')
  function! strager#subvim#send_keys(terminal, keys) abort
    let l:channel_id = getbufvar(a:terminal, '&channel', v:null)
    call chansend(l:channel_id, a:keys)
  endfunction
else
  function! strager#subvim#send_keys(terminal, keys) abort
    call term_sendkeys(a:terminal, a:keys)
  endfunction
endif
