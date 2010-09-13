set sw=4 ts=4 sts=4 et
set cin noai sb spr aw nowrap
set tw=0
set sidescroll=5
set listchars+=precedes:<,extends:>
set foldmethod=marker
set tags+=/usr/local/share/ctags/qt4
set completeopt-=preview
let c_space_errors=1
let c_no_comment_fold=1
let c_no_if0_fold=1
syntax on

highlight comment term=bold cterm=bold ctermfg=4

map <F1> <ESC>:make<CR>
map! <F1> <ESC>:make<CR>
map <F9> :!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>

" Alt-right/left to navigate forward/backward in the tags stack
map <M-Left> <C-T>
map <M-Right> <C-]>

" Automatic C++ header guards
" (http://vim.wikia.com/wiki/Automatic_insertion_of_C/C%2B%2B_header_gates)
function! s:insert_gates()
	let gatename = substitute(toupper(expand("%:t")), "\\.", "_", "g")
	execute "normal! i#ifndef " . gatename
	execute "normal! o#define " . gatename
	execute "normal! Go#endif /* " . gatename . " */"
	normal! O
	normal! O
endfunction
autocmd BufNewFile *.{h,hpp} call <SID>insert_gates()

function! s:insert_js_template()
    let classname = substitute(expand("%:t"), "\\.js$", "", "g")
	execute "normal! iexports.$ = (function () {"

    execute "normal! ovar " . classname . " = function() {"
    execute "normal! <<"
    execute "normal! o};"
    execute "normal! o"
    execute "normal! oreturn " . classname . ";"

	execute "normal! o}());"
    execute "normal! <<"
    execute "normal! 4k0"
endfunction
autocmd BufNewFile [A-Z]*.js call <SID>insert_js_template()

set exrc secure
