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
"                    +0      :CHECK-NEXT-LINE
command Hello let s:a=1|close
