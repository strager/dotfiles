syntax keyword javaScriptImport import nextgroup=javaScriptImportDefault,javaScriptImportNamed,javaScriptImportStar skipwhite
syntax match javaScriptImportDefault /\K\k*/ contained nextgroup=javaScriptImportFrom,javaScriptImportDefaultComma skipwhite
syntax match javaScriptImportDefaultComma /,/ contained nextgroup=javaScriptImportNamed,javaScriptImportStar skipwhite
syntax region javaScriptImportNamed start=/{/ end=/}/ contained contains=ALL keepend nextgroup=javaScriptImportFrom skipwhite
syntax match javaScriptImportStar /\*/ contained nextgroup=javaScriptImportAs skipwhite
syntax keyword javaScriptImportAs as contained nextgroup=javaScriptImportAsNamed skipwhite
syntax match javaScriptImportAsNamed /\K\k*/ contained nextgroup=javaScriptImportFrom skipwhite
syntax keyword javaScriptImportFrom from contained

syntax match javaScriptStringError /\\u[0-9a-fA-F]\{1,3\}\|\\u{[^}]*}\|\\u{\|\\x[0-9a-fA-F]\|\\./
syntax match javaScriptSpecial /\\u[0-9a-fA-F]\{4\}\|\\x[0-9a-fA-F]\{2\}\|\\u{[0-9a-fA-F]\{1,6\}}\|\\[^ux1-9]\|\\\n/
syntax region javaScriptStringD start=/"/ end=/"\|\n/ contains=javaScriptSpecial,javaScriptStringError
syntax region javaScriptStringS start=/'/ end=/'\|\n/ contains=javaScriptSpecial,javaScriptStringError

syntax match javaScriptTemplateError /\\./
syntax match javaScriptTemplateEscape /\\[^ux1-9]\|\\\n/
syntax region javaScriptTemplateSubstitution matchgroup=javaScriptTemplateSubstitutionDelimiter start=/${/ end=/}/ contains=TOP contained
syntax region javaScriptTemplate start=/`/ end=/`/ contains=javaScriptTemplateSubstitution,javaScriptTemplateEscape,javaScriptTemplateError

syntax keyword javaScriptVar const let var

highlight default link javaScriptImport Include
highlight default link javaScriptImportAs Include
highlight default link javaScriptImportFrom Include
highlight default link javaScriptStringError javaScriptError
highlight default link javaScriptTemplate String
highlight default link javaScriptTemplateError javaScriptStringError
highlight default link javaScriptTemplateEscape javaScriptSpecial
highlight default link javaScriptTemplateSubstitutionDelimiter Delimiter
highlight default link javaScriptValue Number
highlight default link javaScriptVar StorageClass
