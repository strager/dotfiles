" Taken (and modified) from haskellmode.
" The rest of their commands are crap.
setlocal errorformat=
  \%-Z\ %#,
  \%W%f:%l:%c:\ Warning:\ %m,
  \%E%f:%l:%c:\ %m,
  \%E%>%f:%l:%c:,
  \%+C\ \ %#%m,
  \%W%>%f:%l:%c:,
  \%+C\ \ %#%tarning:\ %m,
  \%D\%\*\\a[\%\*\\d]:\ Entering\ directory\ `\%f',
  \%X\%\*\\a[\%\*\\d]:\ Leaving\ directory\ `\%f',
  \%D\%\*\\a:\ Entering\ directory\ `\%f',
  \%X\%\*\\a:\ Leaving\ directory\ `\%f',
  \%DMaking\ \%\*\\a\ in\ \%f,

" cin sucks for Haskell.
set nocin ai
