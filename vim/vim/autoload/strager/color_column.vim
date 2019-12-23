function! strager#color_column#set_up_sync_colorcolumn_with_textwidth() abort
  autocmd OptionSet textwidth call <SID>on_set_textwidth({
    \ 'new_textwidth': v:option_new,
    \ 'option_type': v:option_type,
  \ })
endfunction

function! s:on_set_textwidth(options) abort
  let l:textwidth = str2nr(a:options.new_textwidth)
  let l:option_type = a:options.option_type
  if l:option_type ==# 'global'
    let &colorcolumn = l:textwidth
  elseif l:option_type ==# 'local'
    let &l:colorcolumn = l:textwidth
  else
    throw 'Unknown option type: '.string(l:option_type)
  endif
endfunction
