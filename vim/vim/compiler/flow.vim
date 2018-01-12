let s:efm = strager#flow#get_error_format()
call execute('CompilerSet errorformat='.strager#vim#escape_for_set(s:efm))

"CompilerSet makeprg=./node_modules/.bin/flow\ --json\ --quiet\ \\\|\ jq\ --raw-output\ --from-file\ /Users/mg/Projects/dotfiles/vim/vim/autoload/strager/flow.jq
let s:mp = strager#flow#get_make_command('./node_modules/.bin/flow')
call execute('CompilerSet makeprg='.strager#vim#escape_for_set_makeprg(s:mp))
