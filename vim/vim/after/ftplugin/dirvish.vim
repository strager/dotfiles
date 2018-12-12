mapclear <buffer>

nnoremap <buffer><nowait><silent> <Plug>(dirvish_up) :Dirvish %:h:h<CR>
" FIXME(strager): I'd like to use gf for <CR> instead, but its path search
" algorithm finds ~/Projects/vim/ when cwd is ~/Projects/dotfiles/. Figure out
" why.
nnoremap <buffer><nowait><silent><unique> <CR>
  \ :call dirvish#open('edit', v:false)<CR>

nnoremap <buffer><expr><nowait><unique> % ':edit '.expand('%')
nnoremap <buffer><expr><nowait><unique> d ':BrowserMkdir '.expand('%')
nnoremap <buffer><nowait><silent><unique> D
  \ :call strager#directory_browser#prompt_delete_file_under_cursor()<CR>

set readonly
