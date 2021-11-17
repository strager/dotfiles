" HACK(strager): Fix broken scan codes in Vim's gcc.vim's 'errorformat.
" Replace: %D%*\a[%*\d]: Entering directory [`']%f
"    with: %D%*\a[%*\d]: Entering directory %[`']%f
" FIXME(strager): This should respect :CompilerSet but doesn't.
let &errorformat = substitute(&errorformat, 'directory \[`''\]', 'directory %[`'']', 'g')
