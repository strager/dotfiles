" markdown filetype file

if exists("did\_load\_filetypes")
 finish
endif

augroup markdown
 au!
 au BufRead,BufNewFile *.md setfiletype mkd
 au BufRead *.md  set ai formatoptions=tcroqn2 comments=n:&gt;
augroup END
