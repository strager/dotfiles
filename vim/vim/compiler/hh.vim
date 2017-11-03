setlocal makeprg=hh\ --status

" From the example below, parse the first line as an error
" (%E) and related (indented) lines as informational (%I).
"
"   /path/to/file1.php:89:15,29: Could not find method foobar in an object of type WebRequest (Typing[4053])
"     /path/to/controller.php:644:33,49: This is why I think it is an object of type WebRequest
"     /path/to/controller.php:17:28,46:   resulting from expanding the type constant File1::TGetRequest
"     /path/to/file1.php:6:30,39:   resulting from expanding the type constant File1::TRequest
"     /path/to/webrequest.php:4:7,16: Declaration of WebRequest is here
"
" From the example below, hide the message so the quickfix
" list is empty.
"
"   No errors!
setlocal errorformat=
  \%I\ \ %f:%l:%v\\,%*\\d:\ %m,
  \%E%f:%l:%v\\,%*\\d:\ %m,
  \%-GNo\ errors!
