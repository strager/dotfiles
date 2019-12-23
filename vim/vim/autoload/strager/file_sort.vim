function! strager#file_sort#sort_current_buffer() abort
  sort!
  sort! r /\/$/
endfunction
