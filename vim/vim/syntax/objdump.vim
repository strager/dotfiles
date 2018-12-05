scriptencoding utf-8

syntax region objdumpComment start=/#/ end=/$/ contained containedin=objdumpDisassembledInstruction keepend oneline
syntax region objdumpDisassembledInstruction start=/ \t/ end=/$/ keepend oneline
syntax region objdumpSymbolReference matchgroup=objdumpSymbolReferenceDelimiter start=/</ end=/>$/ contained containedin=objdumpDetailedLabel keepend oneline

syntax match objdumpAddress /^ *[0-9a-f]\+:\?/
syntax match objdumpBadInstruction /(bad)/ contained containedin=objdumpDisassembledInstruction
syntax match objdumpDecimalInteger /[0-9]\+/ contained containedin=objdumpDisassembledInstruction
syntax match objdumpDetailedLabel /[0-9a-f]\+ <.*>$/ contained containedin=objdumpComment,objdumpDisassembledInstruction
syntax match objdumpHexInteger /\$0x[0-9a-f]\+/ contained containedin=objdumpDisassembledInstruction
syntax match objdumpHexOffset /[-+]\?0x[0-9a-f]\+/ contained containedin=objdumpDisassembledInstruction,objdumpSymbolReference
syntax match objdumpInstruction /\<[a-z.][A-Za-z0-9.]*\>/ contained containedin=objdumpDisassembledInstruction
syntax match objdumpLabel /[0-9a-f]\+/ contained containedin=objdumpDetailedLabel
syntax match objdumpRegister /%[a-z0-9]\+/ contained containedin=objdumpDisassembledInstruction
syntax match objdumpSymbolDefinition /<.*>/

exec 'syntax match objdumpSymbolReferenceConcealable /'.escape(strager#cxx_symbol#get_conceal_pattern(), '/').'/ cchar=… conceal contained containedin=objdumpSymbolReference'

highlight default link objdumpAddress Comment
highlight default link objdumpBadInstruction Error
highlight default link objdumpComment Comment
highlight default link objdumpDecimalInteger Number
highlight default link objdumpHexInteger Number
highlight default link objdumpHexOffset Number
highlight default link objdumpInstruction Statement
highlight default link objdumpLabel Comment
highlight default link objdumpRegister Identifier
highlight default link objdumpSymbolDefinition Function
highlight default link objdumpSymbolReference Function
highlight default link objdumpSymbolReferenceConcealable Function
