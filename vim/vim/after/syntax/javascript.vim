syntax match javaScriptStringError /\\u[0-9a-fA-F]\{1,3\}\|\\u{[^}]*}\|\\u{\|\\x[0-9a-fA-F]\|\\./
syntax match javaScriptSpecial /\\u[0-9a-fA-F]\{4\}\|\\x[0-9a-fA-F]\{2\}\|\\u{[0-9a-fA-F]\{1,6\}}\|\\[^ux1-9]\|\\\n/
syntax region javaScriptStringD start=/"/ end=/"\|\n/ contains=javaScriptSpecial,javaScriptStringError
syntax region javaScriptStringS start=/'/ end=/'\|\n/ contains=javaScriptSpecial,javaScriptStringError

syntax keyword javaScriptVar const let var

highlight default link javaScriptStringError javaScriptError
highlight default link javaScriptValue Number
highlight default link javaScriptVar StorageClass
