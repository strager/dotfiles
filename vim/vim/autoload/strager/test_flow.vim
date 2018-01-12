" See also some corresponding tests in test_flow_jq.sh.

let s:script_path = expand('<sfile>:p')
let s:script_dir_path = fnamemodify(s:script_path, ':h')

function! Test_flow_jq_sh()
  let l:path = strager#path#join([s:script_dir_path, 'test_flow_jq.sh'])
  let l:output = system(shellescape(l:path))
  call assert_equal(0, v:shell_error)
  call assert_equal('', l:output)
endfunction

function! Test_no_errors()
  let l:lines = []
  let l:result = getqflist({
    \ 'all': v:true,
    \ 'efm': strager#flow#get_error_format(),
    \ 'lines': l:lines,
  \ })
  call assert_equal(0, len(l:result.items))
endfunction

function! Test_parse_error()
  let l:lines = [
    \ '/Users/mg/Projects/pokemon-router/test/money.js:58:11: error: Unexpected string',
  \ ]
  let l:result = getqflist({
    \ 'all': v:true,
    \ 'efm': strager#flow#get_error_format(),
    \ 'lines': l:lines,
  \ })
  call assert_equal(1, len(l:result.items))
  call assert_true(l:result.items[0].valid)
  call assert_equal(bufnr('/Users/mg/Projects/pokemon-router/test/money.js'), l:result.items[0].bufnr)
  call assert_equal(58, l:result.items[0].lnum)
  call assert_equal(11, l:result.items[0].col)
  call assert_equal('E', l:result.items[0].type)
  call assert_equal('Unexpected string', l:result.items[0].text)
endfunction

function! Test_multi_piece_error()
  let l:lines = [
    \ '/Users/mg/Projects/pokemon-router/lib/money.js:14:10: error: string literal `Rock`. This type is incompatible with',
    \ '/Users/mg/Projects/pokemon-router/lib/money.js:12:52: note: string enum',
  \ ]
  let l:result = getqflist({
    \ 'all': v:true,
    \ 'efm': strager#flow#get_error_format(),
    \ 'lines': l:lines,
  \ })
  call assert_equal(2, len(l:result.items))

  call assert_true(l:result.items[0].valid)
  call assert_equal(bufnr('/Users/mg/Projects/pokemon-router/lib/money.js'), l:result.items[0].bufnr)
  call assert_equal(14, l:result.items[0].lnum)
  call assert_equal(10, l:result.items[0].col)
  call assert_equal('E', l:result.items[0].type)
  call assert_equal('string literal `Rock`. This type is incompatible with', l:result.items[0].text)

  call assert_true(l:result.items[1].valid)
  call assert_equal(bufnr('/Users/mg/Projects/pokemon-router/lib/money.js'), l:result.items[1].bufnr)
  call assert_equal(12, l:result.items[1].lnum)
  call assert_equal(52, l:result.items[1].col)
  call assert_equal('I', l:result.items[1].type)
  call assert_equal('string enum', l:result.items[1].text)
endfunction

call strager#test#run_all_tests()
