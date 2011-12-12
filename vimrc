""" General
set nocompatible

""" Plugins
" Log Vim commands
if has('cmdlog')
    set cmdlogdir=~/.vimlogs/
    " set cmdloginsert
end

" Pathogen, activate!
call pathogen#infect()

" Skeleton (Jelly) kept screwing things up,
" so it's disabled for now.
"augroup FileTemplates
"    autocmd!
"    autocmd BufNewFile *.sh TSkeletonSetup prefab/shell.sh
"    autocmd BufNewFile [A-Z]*.php TSkeletonSetup prefab/php.class.php
"    autocmd BufNewFile [a-z]*.php TSkeletonSetup prefab/php.inc.php
"    autocmd BufNewFile *.html TSkeletonSetup prefab/html.html
"    autocmd BufNewFile [A-Z]*.js TSkeletonSetup prefab/js.require.js
"    autocmd BufNewFile *.h TSkeletonSetup prefab/h.h
"augroup END

""" Whitespace, indention, etc.
set sw=4 ts=4 sts=4 et
set nosmartindent
set cin noai
set tw=0

""" Text manipulation
set bs=indent,eol,start
set completeopt=menu,longest

" Make Y consistent with D (i.e. D : d$ :: Y : y$)
nmap Y y$

""" Navigation
set foldmethod=marker

" Sane searching
set hlsearch
set incsearch
set smartcase ignorecase

" TODO Find a better key for this
noremap <ESC><ESC> :nohlsearch<CR>

" Use arrow keys for gj, gk
nmap <Up> gk
nmap <Down> gj

" Alt-j/k to navigate forward/backward in the tags stack
map <M-J> <C-T>
map <M-K> <C-]>

" Use space to find space
" (Note the space after f, F)
" Kinda broken right now...
nmap <Space> ef 

" Use tab for %
nnoremap <tab> %
vnoremap <tab> %

""" Window and tab management
set splitbelow splitright

" Windows
nmap th <C-W>h
nmap tl <C-W>l
nmap tj <C-W>j
nmap tk <C-W>k
nmap ts :split<SPACE>
nmap tv :vsplit<SPACE>
nmap tc <C-W>c

" Tabs
nmap Th :tabp<CR>
nmap Tl :tabn<CR>
nmap Te :tabe<SPACE>
nmap Tn :tabe .<CR>
nmap Tc :tabc<CR>

nmap TH :tabp<CR>
nmap TL :tabn<CR>
nmap TE :tabe<SPACE>
nmap TN :tabe .<CR>
nmap TC :tabc<CR>

nmap tH :tabp<CR>
nmap tL :tabn<CR>
nmap tE :tabe<SPACE>
nmap tN :tabe .<CR>
nmap tC :tabc<CR>

nmap te :tabe<SPACE>

""" File management
set autowrite 

set wildignore+=*/.git/*,*/node_modules/*

" CtrlP goodness (http://kien.github.com/ctrlp.vim/)
nmap ' :CtrlP<CR>
nmap t' :tabnew<CR>:TrlP<CR>
let g:ctrlp_working_path_mode = 0 " Don't touch cwd
let g:ctrlp_max_height = 999
let g:ctrlp_jump_to_buffer = 2 " Not sure if I will like this

""" Display
set nowrap
set ruler
set laststatus=2
set listchars+=precedes:<,extends:>
set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P
set sidescroll=5
set shortmess=a     " Abbreviate status line
set shortmess+=tToO " Other crap

""" Command line
set wildmenu
set wildmode=longest,full

set tags+=/usr/local/share/ctags/qt4

""" Syntax hilighting
syntax on
filetype on
filetype indent on
filetype plugin on

set background=dark
let g:solarized_termtrans=1
colorscheme solarized

highlight StatusLine ctermfg=82
highlight StatusLineNC ctermfg=81
highlight VertSplit ctermfg=16

let c_space_errors=1
let c_no_comment_fold=1
let c_no_if0_fold=1

""" Shortcuts
map <F1> <ESC>:make -j4<CR>
map <F9> :!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>

" Git
nmap gs :!git status -s -b<CR>
nmap gc :!git commit -v<CR>
nmap g. :!git add -p<CR>
nmap g; :!git add -i<CR>
nmap g? :!git diff<CR>
nmap g/ :!git diff --cached<CR>
nmap gv :!git pull --ff --commit<CR>
nmap g^ :!git push<CR>
nmap gp :!git checkout -p<CR>

" Must be last.  Forgot why.
set exrc secure
