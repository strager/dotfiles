runtime! colors/solarized.vim

" Make the vertical split column blend with the line number
" column.
highlight LineNr cterm=bold ctermbg=0 ctermfg=2
if v:version >= 800
  highlight! link CursorLineNr LineNr
endif
highlight VertSplit cterm=bold ctermbg=0 ctermfg=2

" Make the status line blend with the line number column.
"
" HACK(strager): If the following are all true, Vim will
" force the 'fillchars stl item to '^':
"
" * The StatusLine and StatusLine highlight attributes are
"   equivalent
" * The stl and stlnc items are equal
" * The window being drawn is the current window
"
" We don't want this, so choose slightly different colours
" so we hopefully don't notice any difference.
highlight StatusLine cterm=bold ctermbg=0 ctermfg=4
highlight StatusLineNC cterm=bold ctermbg=0 ctermfg=2

highlight SpellBad cterm=bold,undercurl ctermfg=1

let colors_name = 'strager'
