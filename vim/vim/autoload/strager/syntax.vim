function! strager#syntax#begin_syntax() abort
  set regexpengine=1
endfunction

function! strager#syntax#end_syntax() abort
  set regexpengine=0
endfunction

function! strager#syntax#set_text_width_for_vcs_message() abort
  set textwidth=72
  set colorcolumn=72
endfunction
