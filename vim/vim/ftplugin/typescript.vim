" Typescript tries to be helpful.
setlocal makeprg=make

" For some reason, we get some garbage XML indentexpr.
set indentexpr=

let b:ale_linters = ['quick-lint-js']
