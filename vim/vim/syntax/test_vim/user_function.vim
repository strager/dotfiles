" CHECK-ALIAS: " <ignore>
" CHECK-ALIAS: ( vimParenSep
" CHECK-ALIAS: ) vimParenSep
" CHECK-ALIAS: . vimOper
" CHECK-ALIAS: 0 vimNumber
" CHECK-ALIAS: < vimBracket
" CHECK-ALIAS: > vimBracket
" CHECK-ALIAS: ? vimCmdSep|vimCommand|vimIsCommand|vimNumber|vimVar|<none>
" CHECK-ALIAS: C vimCommand|vimNotFunc
" CHECK-ALIAS: F vimFunction
" CHECK-ALIAS: K vimFuncKey
" CHECK-ALIAS: S vimFuncSID
" CHECK-ALIAS: _ <none>
" CHECK-ALIAS: b vimFuncName
" CHECK-ALIAS: n vimNotation
" CHECK-ALIAS: u vimUserFunc
" CHECK-ALIAS: v vimVar

" The name of a user function in a call should be highlighted:
"    ____uuuu():CHECK-NEXT-LINE
call a#b#func()
"    uuuu():CHECK-NEXT-LINE
call Func()
"    uuuuuu():CHECK-NEXT-LINE
call s:func()
"       uuu()   uuu()   uuu()   uuu()   uuu()   uuu():CHECK-NEXT-LINE
let x = s:a() + S:a() + g:b() + G:b() + l:c() + L:c()
"       uuu()   uuu()   uuu()   uuu()   uuu()   uuu():CHECK-NEXT-LINE
let x = b:d() + B:d() + w:e() + W:e() + t:f() + T:f()
"    uuuuuuuuuuuu():CHECK-NEXT-LINE
call my_dict.func()
" TODO(strager): Assert that vimFunc is on the syntax stack for <SID>.
"    <nnn>uuuu():CHECK-NEXT-LINE
call <SID>func()
"    uuuu ( ):CHECK-NEXT-LINE
call Func ( )

" The name of a user function in a declaration should not be highlighted as a
" user function:
" KKKKKKKK FFFF():CHECK-NEXT-LINE
  function Func()
  endfunction
" KKKKKKKK SSFFFFFFFFFFF():CHECK-NEXT-LINE
  function s:my_function()
  endfunction
" TODO(strager): Fix the following:
" KKKKKKKK SSFFFF():TODO-CHECK-NEXT-LINE
" KKKKKKKK SSKKKK():CHECK-NEXT-LINE
  function s:func()
  endfunction

" Broken names should not highlight as user functions:
"    ??():CHECK-NEXT-LINE
call s:()
"    ????():CHECK-NEXT-LINE
call :foo()
"    ????():CHECK-NEXT-LINE
call foo:()
"    ?????():CHECK-NEXT-LINE
call n:bar()
"    ?():CHECK-NEXT-LINE
call %()
"    ???():CHECK-NEXT-LINE
call s:0()
"    0000():CHECK-NEXT-LINE
call 1234()
"    vvvvv():CHECK-NEXT-LINE
call v:foo()
"    vvvvv.uuuuu():CHECK-NEXT-LINE
call l:foo.l:bar()

" Referring to a user function, but not calling it, should not highlight the
" name as a user function:
"    ????:CHECK-NEXT-LINE
call func
"    ??????:CHECK-NEXT-LINE
call s:func

" Built-in functions are not user functions:
"    bbbbbbbbbbb( ):CHECK-NEXT-LINE
call assert_true(0)

" Commands are not user functions:
" CC (   )     :CHECK-NEXT-LINE
  if (2+2) == 4
" CCCCCC (   )     :CHECK-NEXT-LINE
  elseif (1+1) == 2
" CCC (   )     :CHECK-NEXT-LINE
  els (1*1) == 1
  endif
" CCCCC (   )     :CHECK-NEXT-LINE
  while (2*2) == 4
"   CCCCCC ( ):CHECK-NEXT-LINE
    return (x)
  endwhile
