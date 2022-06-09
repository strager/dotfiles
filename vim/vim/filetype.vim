if exists('did_load_filetypes')
 finish
endif

augroup objdump
  au!
  au BufRead,BufNewFile *.objdump setfiletype objdump
augroup END
