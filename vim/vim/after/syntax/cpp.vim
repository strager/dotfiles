let s:optional_namespace = '\(\(\k\+::\)\+\|::\|\)'
let s:optional_template_arguments = '\(<[^>]*>\)\?'

" Match:
" * Types with no sigils: string s;
" * Types with sigials hugging identifier: string *s;
" * Types with sigials hugging type: string* s;
let s:suffixes = [
  \ '\s\k/me=e-2',
  \ '\s[*&]\k/me=e-3',
  \ '\s&&\k/me=e-4',
  \ '[*&]\s\k/me=e-3',
  \ '&&\s\k/me=e-4'
\ ]
for s:suffix in s:suffixes
  call execute('syntax match cInferredType /'.s:optional_namespace.'\k\+'.s:optional_template_arguments.s:suffix)
endfor

" Taken verbatim from Vim's syntax/c.vim. See the vim-license.txt file for its
" license.
" --- BEGIN COPY ---
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last Change:	2019 Nov 29
syn region	cDefine		start="^\s*\zs\(%:\|#\)\s*\(define\|undef\)\>" skip="\\$" end="$" keepend contains=ALLBUT,@cPreProcGroup,@Spell,cInferredType
" --- END COPY ---

highlight default link cInferredType Type

highlight Type ctermfg=3
highlight link StorageClass Keyword
highlight link Structure Keyword
