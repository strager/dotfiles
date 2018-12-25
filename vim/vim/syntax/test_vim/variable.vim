" CHECK-ALIAS: " <ignore>
" CHECK-ALIAS: _ <none>|vimOperParen
" CHECK-ALIAS: C vimCommand
" CHECK-ALIAS: o vimVar

" Option variables:
"   ooo        :CHECK-NEXT-LINE
let &ft = 'vim'
" TODO(strager): Highlight options:
"        ___:CHECK-NEXT-LINE
call Foo(&cp)
" TODO(strager): Highlight options:
"          _CC:CHECK-NEXT-LINE
let l:cp = &cp
" TODO(strager): Highlight options:
"         _CC:CHECK-NEXT-LINE
if l:x || &cp
endif
