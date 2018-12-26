" CHECK-ALIAS: " <ignore>
" CHECK-ALIAS: / vimComment|vimLineComment
" CHECK-ALIAS: ? <none>|vimCommand
" CHECK-ALIAS: \ vimPatSep|vimPatSepErr|vimPatSepZ|vimStringPatternEscape
" CHECK-ALIAS: s vimNotPatSep|vimString|vimStringEnd

" Simple strings in expressions:
"       ss:CHECK-NEXT-LINE
echomsg ""
"       sssssss:CHECK-NEXT-LINE
echomsg "hello"
"       ss:CHECK-NEXT-LINE
echomsg ''
"       sssssss:CHECK-NEXT-LINE
echomsg 'hello'
"        sssssss  ssssssss :CHECK-NEXT-LINE
call foo("hello", "world!")
"        sssssss  ssssssss :CHECK-NEXT-LINE
call foo('hello', 'world!')

" Backslash is not special inside single-quoted strings:
"       ssssssssssssssss:CHECK-NEXT-LINE
echomsg '\%(hello\|\)\n'
"       ssssss ? ?:CHECK-NEXT-LINE
echomsg ' a \' b '

" Backslashes escape quotations in double-quoted strings:
"       ssssssssss:CHECK-NEXT-LINE
echomsg " a \" b "

" Some pattern syntax is highlighted inside double-quoted strings:
"       s\\\s\\s\\sssss:CHECK-NEXT-LINE
echomsg "\%(a\|b\)\{-}"
" Escaped pattern syntax is not highlighted inside double-quoted strings:
"       sssssssssssssssssss:CHECK-NEXT-LINE
echomsg "\\%(a\\|b\\)\\{-}"

" Comments should not look like strings:
" ///////:CHECK-NEXT-LINE
  "hello"
///////:CHECK-NEXT-LINE
"hello"
"          //////:CHECK-NEXT-LINE
call foo() "hello
" TODO(strager): Highlight this as a comment.
"                  ///:TODO-CHECK-NEXT-LINE
"                  sss:CHECK-NEXT-LINE
let g:temp = v:true"b"
