function! strager#tag#go()
  let l:provider_errors = []
  let l:user_errors = []
  let l:error_reporter = s:make_error_reporter(l:provider_errors, l:user_errors)
  if s:go_lsp(l:error_reporter)
    return
  endif
  if s:go_ctags(l:error_reporter)
    return
  endif
  if len(l:user_errors) > 0
    call strager#tag#report_errors(l:user_errors)
  else
    call strager#tag#report_errors(l:provider_errors)
  endif
endfunction

function! strager#tag#report_errors(errors)
  if empty(a:errors)
    echoerr 'Unknown error'
  endif
  for l:error in a:errors
    echomsg l:error
  endfor
endfunction

function s:make_error_reporter(out_provider_errors, out_user_errors)
  let l:reporter = {
    \ 'provider_errors': a:out_provider_errors,
    \ 'user_errors': a:out_user_errors,
  \ }
  function l:reporter.provider_not_available(error)
    call add(self.provider_errors, a:error)
  endfunction
  function l:reporter.provider_error(error)
    call add(self.provider_errors, a:error)
  endfunction
  function l:reporter.no_target(error)
    call add(self.user_errors, a:error)
  endfunction
  function l:reporter.other_error(error)
    call add(self.provider_errors, a:error)
  endfunction
  return l:reporter
endfunction

let s:lsp_timeout_seconds = 5

function! s:go_lsp(error_reporter)
  let l:start_reltime = reltime()

  let l:whitelisted_servers = lsp#get_whitelisted_servers()
  if empty(l:whitelisted_servers)
    call a:error_reporter.provider_not_available(
      \ 'No LSP servers found for filetype "'.&filetype.'"',
    \ )
    return v:false
  endif
  let l:servers = []
  for l:server in l:whitelisted_servers
    if lsp#capabilities#has_definition_provider(l:server)
      call add(l:servers, l:server)
    elseif empty(lsp#get_server_capabilities(l:server))
      call a:error_reporter.provider_not_available(
        \ 'LSP server "'.l:server.'" is not initialized',
      \ )
    else
      call a:error_reporter.provider_not_available(
        \ 'LSP server "'.l:server.'" does not have a definition provider',
      \ )
    endif
  endfor
  if empty(l:servers)
    return v:false
  endif
  if len(l:servers) > 1
    " TODO(strager): Support multiple servers.
    call a:error_reporter.other_error(
      \ 'Too many LSP servers: "'.join(l:servers, '", "').'"',
    \ )
    return v:false
  endif
  let l:server = l:servers[0]

  let l:notification_data = v:none
  let l:got_notification = v:false
  function! On_notification(data) closure
    let l:notification_data = a:data
    let l:got_notification = v:true
  endfunction
  call lsp#send_request(l:server, {
    \ 'method': 'textDocument/definition',
    \ 'on_notification': {data -> On_notification(data)},
    \ 'params': {
    \   'position': lsp#get_position(),
    \   'textDocument': lsp#get_text_document_identifier(),
    \ },
  \ })

  " TODO(strager): Support user interruption (CTRL-C).
  while reltimefloat(reltime(l:start_reltime)) < s:lsp_timeout_seconds
    if l:got_notification
      if lsp#client#is_error(l:notification_data)
        " TODO(strager): Handle errors.
        call a:error_reporter.provider_error(
          \ 'LSP server "'.l:server.'" reported an error',
        \ )
        break
      endif

      let l:locs = lsp#ui#vim#utils#locations_to_loc_list(l:notification_data)
      if len(l:locs) > 1
        " TODO(strager): Support more than one location.
      endif
      if len(l:locs) == 0
        call a:error_reporter.no_target(
          \ 'LSP server "'.l:server.'" found no definitions',
        \ )
        return v:false
      endif
      let l:loc = l:locs[0]
      call s:push_tag(l:loc.filename, l:loc.lnum, l:loc.col)
      return v:true
    endif
    sleep 1m
  endwhile
  " The timeout expired.
  call a:error_reporter.provider_error(
    \ 'Timed out waiting for response from LSP server "'.l:server.'"',
  \ )
  return v:false
endfunction

function! s:go_ctags(error_reporter)
  try
    exec 'normal! '."\<C-]>"
    return v:true
  catch /^Vim(tag):E433:/
    call a:error_reporter.provider_not_available(v:exception)
    return v:false
  catch /^Vim(tag):E426:\|^Vim(normal):E349:/
    call a:error_reporter.no_target(v:exception)
    return v:false
  endtry
endfunction

function! s:push_tag(path, line_number, column_number)
  " TODO(strager): Figure out how to push onto the tag stack.
  " TODO(strager): How do we handle 'switchbuf?
  silent exec 'edit '.fnameescape(a:path)
  " TODO(strager): Should we check for errors?
  call cursor(a:line_number, a:column_number)
endfunction
