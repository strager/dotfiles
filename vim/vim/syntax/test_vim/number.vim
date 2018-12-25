" CHECK-ALIAS: " <ignore>
" CHECK-ALIAS: + vimOper
" CHECK-ALIAS: 0 vimNumber
" CHECK-ALIAS: _ <none>
" CHECK-ALIAS: c vimIsCommand

" Decimal integers:
"       0:CHECK-NEXT-LINE
let x = 1
"       000000000:CHECK-NEXT-LINE
let x = 123456789
"       0000:CHECK-NEXT-LINE
let x = 0009
"        00:CHECK-NEXT-LINE
let x = -42

" Command line numbers:
" 000:CHECK-NEXT-LINE
  186
" 0 0     :CHECK-NEXT-LINE
  3,5write

" Decimal rationals:
"       00000:CHECK-NEXT-LINE
let x = 12.34
"       00000:CHECK-NEXT-LINE
let x = 1.0e5
"       0000000:CHECK-NEXT-LINE
let x = 3.14e-0
"       0000000:CHECK-NEXT-LINE
let x = 3.14e+0

" Invalid decimal rationals:
"       0+:CHECK-NEXT-LINE
let x = 0.
"       0__:CHECK-NEXT-LINE
let x = 1e9
"       +0__:CHECK-NEXT-LINE
let x = .9e0
"       0000_++0:CHECK-NEXT-LINE
let x = 3.14e++0
"       cc+00:CHECK-NEXT-LINE
let x = a3.14

" Hexidecimal integers:
"       000:CHECK-NEXT-LINE
let x = 0xa
"       000000000000000000:CHECK-NEXT-LINE
let x = 0x123456789abcdef0
"       000:CHECK-NEXT-LINE
let x = 0X3
"       00000000000000:CHECK-NEXT-LINE
let x = 0xAbCdEfaBcDeF

" Invalid hexidecimal integers:
"       0_:CHECK-NEXT-LINE
let x = 0x
"       0__:CHECK-NEXT-LINE
let x = 0xg
"       cccccc:CHECK-NEXT-LINE
let x = x12345
"       cccc:CHECK-NEXT-LINE
let x = a0x3
"       0__:CHECK-NEXT-LINE
let x = 1x3
