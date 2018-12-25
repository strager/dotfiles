" CHECK-ALIAS: " <ignore>
" CHECK-ALIAS: ' vimString
" CHECK-ALIAS: + vimOper
" CHECK-ALIAS: M vimMapMod
" CHECK-ALIAS: N vimBracket
" CHECK-ALIAS: \ <ignore>
" CHECK-ALIAS: _ vimOperParen
" CHECK-ALIAS: m vimMapModKey
" CHECK-ALIAS: n vimNotation

" Character codes:
"   NnnnN  :CHECK-NEXT-LINE
map <tab> %

" Command flags:
"        MmmmmmmM MmmmmmmM    :CHECK-NEXT-LINE
nnoremap <buffer> <unique> a a

" Command escape sequences:
"                         NnnnnnN  ''''''''  NnnnnnnN :CHECK-NEXT-LINE
command! Hello call s:foo(<count>, '<bang>', <q-args>)
" TODO(strager): Highlight inside parentheses:
command! Hello call s:foo(
  \ "     NnnnnnN  ''''''''  NnnnnnnN :TODO-CHECK-NEXT-LINE",
  \ "     +_____+  ''''''''  +_+____+ :CHECK-NEXT-LINE",
  \ s:bar(<count>, '<bang>', <q-args>),
\ )

" <SID>:
"    NnnnN      :CHECK-NEXT-LINE
call <SID>func()
