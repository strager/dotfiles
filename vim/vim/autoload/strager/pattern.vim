" Escape a string to serve as a pattern.
"
" The string is matched exactly, case-sensitive.
function! strager#pattern#from_string(string)
  return '\C\V'.strager#pattern#escape_vnm(a:string)
endfunction

" Escape a string for inclusion in a 'very nomagic' (\V) pattern.
function! strager#pattern#escape_vnm(string)
  return escape(a:string, '\')
endfunction
