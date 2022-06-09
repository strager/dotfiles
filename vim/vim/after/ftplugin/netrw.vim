nunmap <buffer> %
nnoremap <buffer><expr><nowait><unique> % ':edit '.expand('%').'/'
nunmap <buffer> d
nnoremap <buffer><expr><nowait><unique> d ':BrowserMkdir '.expand('%').'/'
nunmap <buffer> D
nnoremap <buffer><nowait><silent><unique> D
  \ :call strager#directory_browser#prompt_delete_file_under_cursor()<CR>

set readonly
setlocal nospell
