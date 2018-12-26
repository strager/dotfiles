syntax clear vimFunc
syntax clear vimNotFunc
syntax clear vimOper
syntax clear vimUserFunc

" HACK(strager): Work around substitute function being highlighted as :s. (See
" misc.vim.)
syntax clear vimSubst

syntax keyword vimNotFunc el[seif] if return while
syntax match vimFunc /\%#=1\%([BbGgLlSsTtWw]:\)\?\I\i*\%(\.\I\i*\)*\ze\s*(/ contains=vimFuncName,vimUserFunc
syntax match vimUserFunc /\%#=1[^( ]\+/ contained

syntax match vimOper /&&\|||/ oneline
syntax match vimOper /[=+-]/ oneline
" TODO(strager): Remove contains=vimFunc from vimOper when we define
" vimFunc after vimOper.
" TODO(strager): Remove contains=vimNotation from vimOper when we define
" vimNotation after vimOper.
syntax match vimOper /\%(=[=~]\|![=~]\|[<>]=\?\)[#?]\?/ contains=vimFunc,vimNotation oneline
syntax match vimOper /\<is\%(not\)\?\%(#\|?\|\>\)/ oneline
syntax match vimOper /\./ oneline

" TODO(strager): Remove this rule when we define vimUserAttrb after vimOper.
syntax match vimUserAttribHack /-/ contained containedin=vimUserCmd contains=vimUserAttrb nextgroup=vimUserAttrbCmplt oneline transparent
