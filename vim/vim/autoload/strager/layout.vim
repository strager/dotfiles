function! strager#layout#get_layout_of_windows_and_tabs() abort
  let l:tabs = gettabinfo()
  call map(l:tabs, {_, tab_info -> {
    \ 'winlayout': winlayout(tab_info.tabnr),
    \ 'tabnr': tab_info.tabnr,
  \ }})
  return l:tabs
endfunction
