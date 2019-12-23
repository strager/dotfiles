" vint: -ProhibitAutocmdWithNoGroup

let s:synload_path = strager#path#join([$VIMRUNTIME, 'syntax', 'synload.vim'])
execute printf('source %s', fnameescape(s:synload_path))

" Wrap calls to synload.vim's s:SynSet.
autocmd! Syntax *
autocmd Syntax * call strager#syntax#begin_syntax()
autocmd Syntax * call strager#vim_synload#SynSet()
autocmd Syntax * call strager#syntax#end_syntax()
