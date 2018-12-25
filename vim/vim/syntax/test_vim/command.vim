" CHECK-ALIAS: " <ignore>
" CHECK-ALIAS: + vimOper
" CHECK-ALIAS: - vimOper
" CHECK-ALIAS: C vimUserAttrbCmpltFunc
" CHECK-ALIAS: a vimUserAttrb
" CHECK-ALIAS: c vimUserAttrbCmplt
" CHECK-ALIAS: k vimUserAttrbKey

" :command options:
"        -kkkk        :CHECK-NEXT-LINE
command! -bang Hello w
"        -kkkkk+a        :CHECK-NEXT-LINE
command! -nargs=1 Hello w
"        -kkkkk++        :CHECK-NEXT-LINE
command! -nargs=+ Hello w
"        -kkkkk+a        :CHECK-NEXT-LINE
command! -nargs=? Hello w
"        -kkkkk+a        :CHECK-NEXT-LINE
command! -nargs=* Hello w
"        -kkkkkkkk+ccccccccccCCCCCCC        :CHECK-NEXT-LINE
command! -complete=customlist,s:comp Hello w
