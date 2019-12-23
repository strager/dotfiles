if exists('did_load_filetypes')
 finish
endif

augroup kitten
  au!
  au BufRead,BufNewFile *.ktn setfiletype kitten
augroup END

augroup objdump
  au!
  au BufRead,BufNewFile *.objdump setfiletype objdump
augroup END
