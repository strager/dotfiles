compiler gcc
if has('nvim') || has('patch-8.2.4907')
  set formatoptions+=/
endif

set omnifunc=ale#completion#OmniFunc
