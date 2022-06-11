function! Test_bracketed_paste_in_insert_mode_ignores_indentexpr_etc() abort
  let l:project_path = strager#file#make_directory_with_files(['file.c'])
  let l:file_path = strager#path#join([l:project_path, 'hello.c'])
  let l:terminal = strager#subvim#launch_vim_in_terminal()

  let l:t_PS = &t_PS
  if l:t_PS ==# ''
    " For Neovim.
    let l:t_PS = "\<Esc>[200~"
  endif

  let l:t_PE = &t_PE
  if l:t_PE ==# ''
    " For Neovim.
    let l:t_PE = "\<Esc>[201~"
  endif

  call strager#subvim#run_ex_command(l:terminal, printf(
    \ 'edit %s',
    \ fnameescape(l:file_path),
  \ ))
  call strager#subvim#run_ex_command(l:terminal, 'set nopaste sts=4 sw=4 tw=80')
  call strager#subvim#send_keys(l:terminal, 'i')
  call strager#subvim#send_keys(l:terminal, "int main() {\<CR>// pasting:")
  call strager#subvim#send_keys(l:terminal, l:t_PS."pasted\<CR>second line".l:t_PE)
  call strager#subvim#send_keys(l:terminal, "\<ESC>")
  call strager#subvim#run_ex_command(l:terminal, 'w')

  call assert_equal([
    \ 'int main() {',
    \ '    // pasting:pasted',
    \ 'second line',
  \ ], readfile(l:file_path))
endfunction

call strager#test#run_all_tests()
