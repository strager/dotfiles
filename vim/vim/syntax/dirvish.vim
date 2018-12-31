syntax match dirvishFile ,.\+, oneline
syntax match dirvishDirectory ,[^/]\+/$, oneline
syntax match dirvishParentDirectory ,^.\+/\ze., conceal oneline

highlight default link dirvishDirectory Directory
highlight default link dirvishParentDirectory dirvishDirectory

let b:current_syntax = 'dirvish'
