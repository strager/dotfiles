function! strager#messages#get_messages() abort
  let l:messages_string = execute('messages')
  let l:message_lines = split(l:messages_string, "\n")

  if has('unix') && !(has('patch-8.2.0636') && &helplang ==# '')
    " HACK(strager): Drop the following message:
    "
    " > Messages maintainer: Bram Moolenaar <Bram@vim.org>
    call remove(l:message_lines, 0)
  endif

  return l:message_lines
endfunction

function! strager#messages#get_new_messages(old_messages) abort
  let l:all_messages = strager#messages#get_messages()
  return strager#list#new_messages(a:old_messages, l:all_messages)
endfunction

function! strager#messages#get_messages_limit() abort
  return 201
endfunction
