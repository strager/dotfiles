" CHECK-ALIAS: " <ignore>
" CHECK-ALIAS: C vimCommand
" CHECK-ALIAS: _ <none>|vimOperParen
" CHECK-ALIAS: o vimVar
" CHECK-ALIAS: v vimOperParen|vimVar

" Option variables:
"   ooo        :CHECK-NEXT-LINE
let &ft = 'vim'
" TODO(strager): Highlight options:
"        _vv:CHECK-NEXT-LINE
call Foo(&cp)
"          ooo:CHECK-NEXT-LINE
let l:cp = &cp
"         ooo:CHECK-NEXT-LINE
if l:x || &cp
endif
