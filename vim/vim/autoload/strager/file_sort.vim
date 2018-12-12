function! strager#file_sort#sort_current_buffer()
  sort!
  sort! r /\/$/
endfunction
