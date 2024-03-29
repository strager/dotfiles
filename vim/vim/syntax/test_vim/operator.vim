" CHECK-ALIAS: " <ignore>
" CHECK-ALIAS: + vimOper
" CHECK-ALIAS: _ <none>|vimOperParen
" CHECK-ALIAS: v <none>|vimOperParen|vimVar

" Arithmetic operators:
"     +   +   +  :CHECK-NEXT-LINE
let x = x + 1 - 1
"     ++  :CHECK-NEXT-LINE
let x += 1
"     ++  :CHECK-NEXT-LINE
let x -= 1
"            +   +   :CHECK-NEXT-LINE
let x = min([-x, +y])

" Comparison operators:
"    ++          +++          +++                          :CHECK-NEXT-LINE
if x == y | if x ==# y | if x ==? y | endif | endif | endif
"    ++          +++          +++                          :CHECK-NEXT-LINE
if x != y | if x !=# y | if x !=? y | endif | endif | endif
"    +          ++          ++                          :CHECK-NEXT-LINE
if x > y | if x ># y | if x >? y | endif | endif | endif
"    ++          +++          +++                          :CHECK-NEXT-LINE
if x >= y | if x >=# y | if x >=? y | endif | endif | endif
"    +          ++          ++                          :CHECK-NEXT-LINE
if x < y | if x <# y | if x <? y | endif | endif | endif
"    ++          +++          +++                          :CHECK-NEXT-LINE
if x <= y | if x <=# y | if x <=? y | endif | endif | endif
"    ++          +++          +++                          :CHECK-NEXT-LINE
if x =~ y | if x =~# y | if x =~? y | endif | endif | endif
"    ++          +++          +++                          :CHECK-NEXT-LINE
if x !~ y | if x !~# y | if x !~? y | endif | endif | endif
"    ++          +++          +++                          :CHECK-NEXT-LINE
if x is y | if x is? y | if x is# y | endif | endif | endif
"    +++++          ++++++          ++++++                          :CHECK-NEXT-LINE
if x isnot y | if x isnot? y | if x isnot# y | endif | endif | endif

" Logical operators:
"    ++   ++          :CHECK-NEXT-LINE
if x && y || z | endif

" Other operators:
"     +   +  :CHECK-NEXT-LINE
let x = x . y
"     ++  :CHECK-NEXT-LINE
let x .= y

" Not operators:
"      _          :CHECK-NEXT-LINE
if a =~~ b | endif
"    vvvv         :CHECK-NEXT-LINE
if F(isnt) | endif
"    vvvvv         :CHECK-NEXT-LINE
if F(notis) | endif
"    vvvvvv         :CHECK-NEXT-LINE
if F(xisnot) | endif
"      _     _          :CHECK-NEXT-LINE
if a &&? b ||? c | endif
"      _     _          :CHECK-NEXT-LINE
if a &&# b ||# c | endif
"     _           _                  :CHECK-NEXT-LINE
if a =? b | if a =# b | endif | endif

" TODO(strager): Highlight more operators:
"         +   +   +  :TODO-CHECK-NEXT-LINE
let x = x * 2 / 2 % 3
"         +   +  :TODO-CHECK-NEXT-LINE
let r = x ? y : z
"  +         +               :TODO-CHECK-NEXT-LINE
if !l:foo && !(x < y) | endif
