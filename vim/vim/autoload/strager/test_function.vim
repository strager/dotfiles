let s:script_path = expand('<sfile>:p')

" **MARKER Test_function_source_location_of_user_function MARKER**
function! Test_function_source_location_of_user_function() abort
  let l:local = {}
  function! l:local.check(function) abort
    let l:loc = strager#function#function_source_location(a:function)
    call assert_equal(s:test_marker_line_number(
      \ 'Test_function_source_location_of_user_function',
    \ ), l:loc.line)
    call assert_equal(
      \ 'Test_function_source_location_of_user_function',
      \ l:loc.real_name,
    \ )
    call assert_equal(
      \ 'Test_function_source_location_of_user_function',
      \ l:loc.source_name,
    \ )
    call assert_equal(s:script_path, l:loc.script_path)
  endfunction

  " User function by name string.
  call l:local.check('Test_function_source_location_of_user_function')
  " User function by funcref.
  call l:local.check(funcref('Test_function_source_location_of_user_function'))
  " User function by partial.
  call l:local.check(funcref(
    \ 'Test_function_source_location_of_user_function',
    \ ['args', 'go', 'here'],
  \ ))
endfunction

function! Test_function_source_location_of_script_function() abort
  let l:local = {}
  function! l:local.check(function) abort
    let l:loc = strager#function#function_source_location(a:function)
    call assert_equal(
      \ s:test_marker_line_number('s:script_function'),
      \ l:loc.line,
    \ )
    call assert_equal(
      \ "\x80\xfdR".s:sid().'_script_function',
      \ l:loc.real_name,
    \ )
    call assert_equal(
      \ 's:script_function',
      \ l:loc.source_name,
    \ )
    call assert_equal(s:script_path, l:loc.script_path)
  endfunction

  " Script function by real name string.
  call l:local.check(get(funcref('s:script_function'), 'name'))
  " Script function by SNR name string.
  call l:local.check('<SNR>'.s:sid().'_script_function')
endfunction

function! Test_function_source_location_of_built_in_function() abort
  " Built-in function by name string.
  let l:loc = strager#function#function_source_location('getbufinfo')
  call assert_equal(v:null, l:loc.line)
  call assert_equal('getbufinfo', l:loc.real_name)
  call assert_equal(v:null, l:loc.script_path)
  call assert_equal(v:null, l:loc.source_name)

  " Built-in function by dynamic funcref.
  let l:loc = strager#function#function_source_location(function('getbufinfo'))
  call assert_equal(v:null, l:loc.line)
  call assert_equal('getbufinfo', l:loc.real_name)
  call assert_equal(v:null, l:loc.script_path)
  call assert_equal(v:null, l:loc.source_name)
endfunction

function! Test_function_source_location_of_live_lambda() abort
  " **MARKER Test_function_source_location_of_live_lambda lambda MARKER**
  let l:lambda = [{-> hello(world)}]
  let l:loc = strager#function#function_source_location(l:lambda[0])

  " FIXME(strager): For some reason, :function reports the line *before* 'let
  " l:lambda = ...' as the lambda's source line. Figure out why.
  call assert_equal(s:test_marker_line_number(
    \ 'Test_function_source_location_of_live_lambda lambda',
  \ ) - 1, l:loc.line)
  let l:lambda_name = matchlist(string(l:lambda[0]), "function('\\(.*\\)')")[1]
  call assert_equal(l:lambda_name, l:loc.real_name)
  call assert_equal(v:null, l:loc.source_name, 'Lambdas should have no name')
  call assert_equal(s:script_path, l:loc.script_path)
endfunction

function! Test_function_source_location_of_dead_lambda() abort
  let l:lambda = [{-> hello(world)}]
  let l:lambda_name = get(l:lambda[0], 'name')
  let l:lambda[0] = v:null
  let l:loc = strager#function#function_source_location(l:lambda_name)

  call assert_equal(
    \ v:null,
    \ l:loc.line,
    \ 'Dead lambdas should not have a source location',
  \ )
  call assert_equal(l:lambda_name, l:loc.real_name)
  call assert_equal(v:null, l:loc.source_name, 'Lambdas should have no name')
  call assert_equal(
    \ v:null,
    \ l:loc.script_path,
    \ 'Dead lambdas should not have a source location',
  \ )
endfunction

function! Test_function_source_location_of_unloaded_autoload_function() abort
  let l:loc = strager#function#function_source_location(
    \ 'strager#test_function_helper_unloaded#func',
  \ )
  call assert_equal(v:null, l:loc.line)
  call assert_equal(
    \ 'strager#test_function_helper_unloaded#func',
    \ l:loc.real_name,
  \ )
  call assert_equal(v:null, l:loc.script_path)
  call assert_equal(v:null, l:loc.source_name)
endfunction

function! Test_function_source_location_of_loaded_autoload_function() abort
  let l:local = {}
  function! l:local.check(function) abort
    let l:loc = strager#function#function_source_location(a:function)
    call assert_equal(2, l:loc.line)
    call assert_equal('strager#test_function_helper#func', l:loc.real_name)
    call assert_equal('strager#test_function_helper#func', l:loc.source_name)
    call assert_equal(strager#path#join([
      \ fnamemodify(s:script_path, ':h'),
      \ 'test_function_helper.vim',
    \ ]), l:loc.script_path)
  endfunction

  " Ensure the function is loaded.
  call strager#test_function_helper#func()

  " Autoload function by name string.
  call l:local.check('strager#test_function_helper#func')
  " Autoload function by funcref.
  call l:local.check(funcref('strager#test_function_helper#func'))
  " Autoload function by partial.
  call l:local.check(funcref(
    \ 'strager#test_function_helper#func',
    \ ['args', 'go', 'here'],
  \ ))
endfunction

" Test that s:function_with_common_prefix isn't confused for
" s:function_with_common_prefix2.
function! Test_function_source_location_of_functions_with_common_prefix() abort
  let l:loc = strager#function#function_source_location(
    \ funcref('s:function_with_common_prefix'),
  \ )
  call assert_equal(
    \ s:test_marker_line_number('s:function_with_common_prefix'),
    \ l:loc.line,
  \ )
endfunction

function! Test_parse_ex_function_output() abort
  " Sample output of ':verbose function NetrwStatusLine' after Vim patch 8.1.0362:
  let l:ex_function_output = join([
    \ '   function NetrwStatusLine()',
    \ '        Last set from /nix/store/3w803z680i95mi5fasf2pxbwpv1cb94g-vim-8.1.0450/share/vim/vim81/plugin/netrwPlugin.vim line 167',
    \ '1  "  let g:stlmsg= "Xbufnr=".w:netrw_explore_bufnr." bufnr=".bufnr("%")." Xline#".w:netrw_explore_line." line#".line(".")',
    \ '2    if !exists("w:netrw_explore_bufnr") || w:netrw_explore_bufnr != bufnr("%") || !exists("w:netrw_explore_line") || w:netrw_explore_line != line(".") || !exists("w:netrw_explore_list")',
    \ '3     let &stl= s:netrw_explore_stl',
    \ '4     if exists("w:netrw_explore_bufnr")|unlet w:netrw_explore_bufnr|endif',
    \ '5     if exists("w:netrw_explore_line")|unlet w:netrw_explore_line|endif',
    \ '6     return ""',
    \ '7    else',
    \ '8     return "Match ".w:netrw_explore_mtchcnt." of ".w:netrw_explore_listlen',
    \ '9    endif',
    \ '   endfunction',
  \ ], "\n")
  let l:function_info = strager#function#parse_ex_function_output(l:ex_function_output)
  call assert_equal('/nix/store/3w803z680i95mi5fasf2pxbwpv1cb94g-vim-8.1.0450/share/vim/vim81/plugin/netrwPlugin.vim', l:function_info.script_path)
  call assert_equal(167, l:function_info.line)
endfunction

function! Test_parse_ex_function_output_with_tilde_in_script_path() abort
  " Sample output of ':verbose function fzf#shellescape'.
  let l:ex_function_output = join([
    \ '   function fzf#shellescape(arg, ...)',
    \ '        Last set from ~/Projects/dotfiles/vim/vim/bundle/fzf/plugin/fzf.vim line 77',
    \ '1    let shell = get(a:000, 0, &shell)',
    \ "2    if shell =~# 'cmd.exe$'",
    \ '3      return s:shellesc_cmd(a:arg)',
    \ '4    endif',
    \ "5    return s:fzf_call('shellescape', a:arg)",
    \ '   endfunction',
  \ ], "\n")
  let l:function_info = strager#function#parse_ex_function_output(l:ex_function_output)
  call assert_equal('~/Projects/dotfiles/vim/vim/bundle/fzf/plugin/fzf.vim', l:function_info.script_path)
  call assert_equal(77, l:function_info.line)
endfunction

function! Test_parse_old_ex_function_output() abort
  " Sample output of ':verbose function NetrwStatusLine' before Vim patch 8.1.0362:
  let l:ex_function_output = join([
    \ '   function NetrwStatusLine()',
    \ '        Last set from /nix/store/880405p4px2lgjnizg5pd68gwcdv2w0q-vim-8.0.1655/share/vim/vim80/plugin/netrwPlugin.vim',
    \ '1  "  let g:stlmsg= "Xbufnr=".w:netrw_explore_bufnr." bufnr=".bufnr("%")." Xline#".w:netrw_explore_line." line#".line(".")',
    \ '2    if !exists("w:netrw_explore_bufnr") || w:netrw_explore_bufnr != bufnr("%") || !exists("w:netrw_explore_line") || w:netrw_explore_line != line(".") || !exists("w:netrw_explore_list")',
    \ '3     let &stl= s:netrw_explore_stl',
    \ '4     if exists("w:netrw_explore_bufnr")|unlet w:netrw_explore_bufnr|endif',
    \ '5     if exists("w:netrw_explore_line")|unlet w:netrw_explore_line|endif',
    \ '6     return ""',
    \ '7    else',
    \ '8     return "Match ".w:netrw_explore_mtchcnt." of ".w:netrw_explore_listlen',
    \ '9    endif',
    \ '   endfunction',
  \ ], "\n")
  let l:function_info = strager#function#parse_ex_function_output(l:ex_function_output)
  call assert_equal('/nix/store/880405p4px2lgjnizg5pd68gwcdv2w0q-vim-8.0.1655/share/vim/vim80/plugin/netrwPlugin.vim', l:function_info.script_path)
  call assert_equal(v:null, l:function_info.line)
endfunction

function! Test_parse_ex_function_output_with_missing_path() abort
  " Sample output of ':function NetrwStatusLine':
  let l:ex_function_output = join([
    \ '   function NetrwStatusLine()',
    \ '1  "  let g:stlmsg= "Xbufnr=".w:netrw_explore_bufnr." bufnr=".bufnr("%")." Xline#".w:netrw_explore_line." line#".line(".")',
    \ '2    if !exists("w:netrw_explore_bufnr") || w:netrw_explore_bufnr != bufnr("%") || !exists("w:netrw_explore_line") || w:netrw_explore_line != line(".") || !exists("w:netrw_explore_list")',
    \ '3     let &stl= s:netrw_explore_stl',
    \ '4     if exists("w:netrw_explore_bufnr")|unlet w:netrw_explore_bufnr|endif',
    \ '5     if exists("w:netrw_explore_line")|unlet w:netrw_explore_line|endif',
    \ '6     return ""',
    \ '7    else',
    \ '8     return "Match ".w:netrw_explore_mtchcnt." of ".w:netrw_explore_listlen',
    \ '9    endif',
    \ '   endfunction',
  \ ], "\n")
  let l:function_info = strager#function#parse_ex_function_output(l:ex_function_output)
  call assert_equal(v:null, l:function_info.script_path)
  call assert_equal(v:null, l:function_info.line)
endfunction

" **MARKER s:script_function MARKER**
function! s:script_function() abort
endfunction

function! s:function_with_common_prefix_() abort
endfunction

" **MARKER s:function_with_common_prefix MARKER**
function! s:function_with_common_prefix() abort
endfunction

function! s:function_with_common_prefix2() abort
endfunction

function! s:sid() abort
  " See: :help <SID>
  return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_sid$')
endfun

function! s:test_marker_line_number(marker_name) abort
  " FIXME(strager): Is this the correct way to escape?
  let l:pattern = '\*\*MARKER '.escape(a:marker_name, '').' MARKER\*\*'
  let l:cur_line_number = 1
  for l:line in readfile(s:script_path)
    if match(l:line, l:pattern) != -1
      " Return the number of the line after the marker.
      return l:cur_line_number + 1
    endif
    let l:cur_line_number += 1
  endfor
  throw 'Could not find marker: '.a:marker_name
endfunction

call strager#test#run_all_tests()
