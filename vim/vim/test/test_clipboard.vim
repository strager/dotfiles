function! Test_bracketed_paste_in_insert_mode_ignores_indentexpr_etc() abort
  let l:project_path = strager#file#make_directory_with_files(['file.c'])
  let l:file_path = strager#path#join([l:project_path, 'hello.c'])
  let l:terminal = strager#subvim#launch_vim_in_terminal()

  call strager#subvim#run_ex_command(l:terminal, printf(
    \ 'edit %s',
    \ fnameescape(l:file_path),
  \ ))
  call strager#subvim#run_ex_command(l:terminal, 'set nopaste sts=4 sw=4 tw=80')
  call term_sendkeys(l:terminal, 'i')
  call term_sendkeys(l:terminal, "int main() {\<CR>// pasting:")
  call term_sendkeys(l:terminal, "\<t_PS>pasted\<CR>second line\<t_PE>")
  call term_sendkeys(l:terminal, "\<ESC>")
  call strager#subvim#run_ex_command(l:terminal, 'w')

  call assert_equal([
    \ 'int main() {',
    \ '    // pasting:pasted',
    \ 'second line',
  \ ], readfile(l:file_path))
endfunction

call strager#test#run_all_tests()
