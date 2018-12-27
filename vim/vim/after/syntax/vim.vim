syntax clear vimFunc
syntax clear vimNotFunc
syntax clear vimNotPatSep
syntax clear vimNumber
syntax clear vimOper
syntax clear vimString
syntax clear vimUserFunc

" HACK(strager): Work around substitute function being highlighted as :s. (See
" misc.vim.)
syntax clear vimSubst

syntax keyword vimNotFunc el[seif] if return while
syntax match vimFunc /\%([BbGgLlSsTtWw]:\)\?\I\i*\%(\.\I\i*\)*\ze\s*(/ contains=vimFuncName,vimUserFunc
syntax match vimUserFunc /[^( ]\+/ contained

syntax match vimNumber /\<\d\+\%(\.\d\+\%(e\%([-+]\d\|\d\)\)\?\)\?/ oneline
syntax match vimNumber /0[Xx]\x\+/ oneline

syntax match vimOper /&&\|||/ oneline
syntax match vimOper /[=+-]/ oneline
" TODO(strager): Remove contains=vimFunc from vimOper when we define
" vimFunc after vimOper.
" TODO(strager): Remove contains=vimNotation from vimOper when we define
" vimNotation after vimOper.
syntax match vimOper /\%(=[=~]\|![=~]\|[<>]=\?\)[#?]\?/ contains=vimFunc,vimNotation oneline
syntax match vimOper /\<is\%(not\)\?\%(#\|?\|\>\)/ oneline
syntax match vimOper /\./ oneline

syntax match vimNotPatSep /\\\\/ contained
syntax match vimString /'[^']*'/
syntax match vimStringPatternEscape /\\%(/ contained
syntax match vimStringPatternEscape /\\)/ contained
syntax match vimStringPatternEscape /\\|/ contained
syntax region vimString start=+/+ end=+/+ oneline
syntax region vimString start=/^\@<!"/ skip=/\\"/ matchgroup=vimStringEnd end=/"/ oneline contains=vimNotPatSep,vimStringPatternEscape

" TODO(strager): Remove this rule when we define vimUserAttrb after vimOper.
syntax match vimUserAttribHack /-/ contained containedin=vimUserCmd contains=vimUserAttrb nextgroup=vimUserAttrbCmplt oneline transparent

" HACK(strager): Remove vimNotPatSep from vimSynRegPatGroup. (Why is it there in
" the first place?)
syntax cluster vimSynRegPatGroup contains=vimPatSep,vimSynPatRange,vimSynNotPatRange,vimSubstSubstr,vimPatRegion,vimPatSepErr,vimNotation

highlight default link vimStringPatternEscape vimPatSep
