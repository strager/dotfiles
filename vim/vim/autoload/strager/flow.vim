let s:script_path = expand('<sfile>:p')
let s:script_dir_path = fnamemodify(s:script_path, ':h')
let s:make_jq_script_path = strager#path#join([s:script_dir_path, 'flow.jq'])

function! strager#flow#get_make_command(flow_program_path)
  return shellescape(a:flow_program_path).' --json --quiet'
    \ .' | jq --raw-output --from-file '.shellescape(s:make_jq_script_path)
endfunction

function! strager#flow#get_error_format()
  return join([
    \ '%E%f:%l:%c: error: %m',
    \ '%I%f:%l:%c: note: %m',
  \ ], ',')
endfunction
