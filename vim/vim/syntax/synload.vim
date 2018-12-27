let s:synload_path = strager#path#join([$VIMRUNTIME, 'syntax', 'synload.vim'])
execute printf('source %s', fnameescape(s:synload_path))

" Wrap calls to synload.vim's s:SynSet.
let s:synload_script_number = strager#script#number_of_loaded_script(s:synload_path)
autocmd! Syntax *
autocmd Syntax * call strager#syntax#begin_syntax()
execute printf("autocmd Syntax * call <SNR>%d_SynSet()", s:synload_script_number)
autocmd Syntax * call strager#syntax#end_syntax()
