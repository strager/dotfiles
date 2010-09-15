set sw=4 ts=4 sts=4 et
set cin noai sb spr aw nowrap
set tw=0
set incsearch
set nocompatible
set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P
set sidescroll=5
set listchars+=precedes:<,extends:>
set foldmethod=marker
set tags+=/usr/local/share/ctags/qt4
set completeopt-=preview
let c_space_errors=1
let c_no_comment_fold=1
let c_no_if0_fold=1

syntax on
filetype on
filetype indent on
filetype plugin on

highlight comment term=bold cterm=bold ctermfg=4

highlight StatusLine ctermfg=82
highlight StatusLineNC ctermfg=81
highlight VertSplit ctermfg=16

map <F1> <ESC>:make<CR>
map! <F1> <ESC>:make<CR>
map <F9> :!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>

" Alt-right/left to navigate forward/backward in the tags stack
map <M-Left> <C-T>
map <M-Right> <C-]>

" Tab navigation
nmap th :tabp<CR>
nmap tl :tabn<CR>
nmap te :tabe<SPACE>
nmap tn :tabe .<CR>
nmap tc :tabc<CR>

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

function! s:insert_js_template()
    let classname = substitute(expand("%:t"), "\\.js$", "", "g")

    " Clear buffer
    execute "normal! [[d]]"

    execute "normal! iexports.$ = (function () {"

    execute "normal! ovar " . classname . " = function() {"
    " Lame bug fix
    execute "normal! <<"
    execute "normal! o};"
    execute "normal! o"
    execute "normal! oreturn " . classname . ";"

    execute "normal! o}());"
    " Lame bug fix
    execute "normal! <<"
    execute "normal! 4k0"
endfunction

function! s:insert_js_test_template()
    let classname = substitute(expand("%:t"), "\\.js$", "", "g")
    let classpath = expand("%:r")
    let classpath = substitute(classpath, "^tests\\?/", "", "")

    " Clear buffer
    execute "normal! [[d]]"

    execute "normal! i(function () {"

    execute "normal! ovar assert = require('assert');"
    " Lame bug fix
    execute "normal! <<>>"
    execute "normal! ovar " . classname . " = require('" . classpath . "');"
    execute "normal! o"

    " Lame bug fix
    execute "normal! o}());"
    execute "normal! <<"
    execute "normal! 1k0"
endfunction

augroup FileTemplates
    autocmd!
    autocmd BufNewFile *.{h,hpp} call <SID>insert_gates()
    autocmd BufNewFile [A-Z]*.js call <SID>insert_js_template()
    autocmd BufNewFile */test{,s}/*/[A-Z]*.js call <SID>insert_js_test_template()
augroup END

set exrc secure
