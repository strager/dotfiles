" Typescript tries to be helpful.
setlocal makeprg=make

" For some reason, we get some garbage XML indentexpr by default.
runtime! indent/javascript.vim
set indentexpr=GetJsIndent()

let b:ale_linters = ['quick-lint-js']
