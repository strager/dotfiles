" Returns a list of 'comments parts. Use this function in ftplugin-s.
function! strager#c_syntax#get_c_style_comments() abort
  return ['sO:*\ -', 'mO:*\ \ ', 'exO:*/', 's1:/*', 'mb:*', 'ex:*/', '://']
endfunction

