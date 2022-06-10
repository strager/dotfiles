nunmap <buffer> %
nnoremap <buffer><expr><nowait> % ':edit '.expand('%').'/'
nunmap <buffer> d
nnoremap <buffer><expr><nowait> d ':BrowserMkdir '.expand('%').'/'
nunmap <buffer> D
nnoremap <buffer><nowait><silent> D
  \ :call strager#directory_browser#prompt_delete_file_under_cursor()<CR>

set readonly
setlocal nospell
