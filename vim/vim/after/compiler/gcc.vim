" HACK(strager): vim-lsp's interface is so confusing. Instead of just giving
" vim-lsp the config, we must hand vim-lsp a callback (au User lsp_setup) so we
" can hand vim-lsp a callback (lsp#register_server()) which returns the config.
" Otherwise, lsp#disable() followed by lsp#enable() doesn't re-enable the server
" properly.
augroup strager_compiler_gcc
  au!
  au User lsp_setup call strager#lsp#register_clangd_server()
augroup END
