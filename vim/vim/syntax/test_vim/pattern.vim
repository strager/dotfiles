" CHECK-ALIAS: " <ignore>
" CHECK-ALIAS: ( vimPatSepR
" CHECK-ALIAS: ) vimPatSepR
" CHECK-ALIAS: / vimSynNotPatRange
" CHECK-ALIAS: E vimPatSepErr
" CHECK-ALIAS: \ vimSubstTwoBS
" CHECK-ALIAS: r vimString|vimSynRegPat
" CHECK-ALIAS: s vimPatSep
" CHECK-ALIAS: | vimPatSep

" Patterns are highlighted:
"              rrrrr:CHECK-NEXT-LINE
syntax match a /abc/
"              rrrrr:CHECK-NEXT-LINE
syntax match a +abc+
try
"     r rrrrr:CHECK-NEXT-LINE
catch /^E123/
endtry
"       r rrrr:CHECK-NEXT-LINE
sort! r /^abc/
"                        r rrrr:CHECK-NEXT-LINE
let matches = 'hello' =~ /^abc/

" Some pattern syntax is highlighted inside syntax patterns:
"               (((\\     ||  )) ((()) (()):CHECK-NEXT-LINE
syntax match a /\%(\\\{4\}\|\.\) \z(\) \(\)/
" FIXME(strager): Why does \\ not highlight as vimSubstTwoBS?
"               // ||//  :CHECK-NEXT-LINE
syntax match a /\\u\|\\u/

" Invalid patterns highlight differently than valid patterns:
"               EE rr    :CHECK-NEXT-LINE
syntax match a /\) \(foo/
