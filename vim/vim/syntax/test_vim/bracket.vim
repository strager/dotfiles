" CHECK-ALIAS: " <ignore>
" CHECK-ALIAS: ' vimString
" CHECK-ALIAS: M vimMapMod
" CHECK-ALIAS: N vimBracket
" CHECK-ALIAS: \ <ignore>
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
command! Hello call s:foo(
  \ "     NnnnnnN  ''''''''  NnnnnnnN :CHECK-NEXT-LINE",
  \ s:bar(<count>, '<bang>', <q-args>),
\ )

" <SID>:
"    NnnnN      :CHECK-NEXT-LINE
call <SID>func()
