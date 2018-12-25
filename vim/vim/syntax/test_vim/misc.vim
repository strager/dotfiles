" CHECK-ALIAS: " <ignore>
" CHECK-ALIAS: f vimFuncName
" CHECK-ALIAS: ( vimOperParen

function s:func()
  "             ffffffffff  :CHECK-NEXT-LINE
  let escaped = substitute()
  "                          (    :CHECK-NEXT-LINE
  let l:i = match(v:statusmsg, '')
endfunction
