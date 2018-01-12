function! strager#vim#escape_for_set(string)
  return escape(a:string, ' \"|')
endfunction

function! strager#vim#escape_for_set_makeprg(command)
  return strager#vim#escape_for_set(escape(a:command, '|'))
endfunction
