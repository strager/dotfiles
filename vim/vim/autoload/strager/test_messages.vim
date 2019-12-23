function! Test_messages_includes_echomsg() abort
  echomsg 'Test_messages_includes_echomsg message'
  let l:messages = strager#messages#get_messages()
  call assert_equal('Test_messages_includes_echomsg message', l:messages[-1])
endfunction

function! Test_messages_are_limited() abort
  let l:messages_limit = strager#messages#get_messages_limit()

  let l:expected_messages = []
  call add(l:expected_messages, 'Test_messages_are_limited second')
  for l:i in range(3, l:messages_limit - 1)
    call add(l:expected_messages, printf('Test_messages_are_limited %d', l:i))
  endfor
  call add(l:expected_messages, 'Test_messages_are_limited last')
  call add(l:expected_messages, 'Test_messages_are_limited overflow')
  call assert_equal(l:messages_limit, len(l:expected_messages))

  messages clear
  echomsg 'Test_messages_are_limited first'
  for l:message in l:expected_messages
    echomsg l:message
  endfor

  let l:messages = strager#messages#get_messages()
  call assert_equal(l:messages_limit, len(l:messages))
  call assert_equal(l:expected_messages, l:messages)
endfunction

function! Test_no_messages_after_clear() abort
  echomsg 'Test_no_messages_after_clear message'
  messages clear
  let l:messages = strager#messages#get_messages()
  call assert_equal([], l:messages)
endfunction

function! Test_new_messages_includes_echomsg() abort
  let l:messages = strager#messages#get_messages()
  echomsg 'Test_new_messages_includes_echomsg message'
  let l:new_messages = strager#messages#get_new_messages(l:messages)
  call assert_equal(
    \ ['Test_new_messages_includes_echomsg message'],
    \ l:new_messages,
  \ )
endfunction

function! Test_new_messages_includes_echomsg_after_clear() abort
  let l:messages = strager#messages#get_messages()
  echomsg 'Test_new_messages_includes_echomsg_after_clear message 1'
  echomsg 'Test_new_messages_includes_echomsg_after_clear message 2'
  echomsg 'Test_new_messages_includes_echomsg_after_clear message 3'
  messages clear
  echomsg 'Test_new_messages_includes_echomsg_after_clear message 4'
  let l:new_messages = strager#messages#get_new_messages(l:messages)
  call assert_equal(
    \ ['Test_new_messages_includes_echomsg_after_clear message 4'],
    \ l:new_messages,
  \ )
endfunction

function! Test_new_messages_includes_echomsg_if_full() abort
  call s:fill_message_list()
  let l:messages = strager#messages#get_messages()
  echomsg 'Test_new_messages_includes_echomsg_if_full message'
  let l:new_messages = strager#messages#get_new_messages(l:messages)
  call assert_equal(
    \ ['Test_new_messages_includes_echomsg_if_full message'],
    \ l:new_messages,
  \ )
endfunction

function! s:fill_message_list() abort
  for l:_ in range(strager#messages#get_messages_limit())
    echomsg 'fill_message_list filler'
  endfor
endfunction

call strager#test#run_all_tests()
