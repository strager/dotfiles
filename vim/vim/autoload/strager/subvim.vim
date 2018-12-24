function! strager#subvim#launch_vim_in_terminal()
  execute printf(
    \ 'terminal ++noclose ++rows=10 ++cols=80 %s -n',
    \ fnameescape(v:progpath),
  \ )
  return bufnr('%')
endfunction

function! strager#subvim#run_ex_command(terminal, ex_command)
  call term_sendkeys(a:terminal, ':'.a:ex_command."\<CR>")
  sleep 100m
  call term_wait(a:terminal)
endfunction

