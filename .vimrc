set sw=4 ts=4 cin noai sb spr aw nowrap
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
map <F2> :make oswan<CR>
map! <F2> :make oswan<CR>
map <F3> :make && exec nocash *.nds &<CR>
map <F9> :!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>

" Declaration => Implementation
map <F8> :GHPH

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

set exrc secure
