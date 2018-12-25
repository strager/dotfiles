" CHECK-ALIAS: " <ignore>
" CHECK-ALIAS: + vimOper
" CHECK-ALIAS: 0 vimNumber
" CHECK-ALIAS: = vimSetEqual

" let:
"     +  :CHECK-NEXT-LINE
let x = 1
"        + :CHECK-NEXT-LINE
let s:var=1

" let inside :command:
" TODO(strager): Highlight = as an operator and 1 as a number.
"                    +0      :TODO-CHECK-NEXT-LINE
"                    ==      :CHECK-NEXT-LINE
command Hello let s:a=1|close
