function! strager#random_mt19937#make_generator(seed)
  if !has('num64')
    throw 'ES002: mt19937 is not available in this version'
  endif
  let l:rng = {
    \ '_mt': repeat([0], s:n),
    \ '_mti': s:n + 1,
  \ }
  let l:seed_type = type(a:seed)
  if l:seed_type ==# v:t_list
    call s:init_by_array(l:rng, a:seed)
  elseif l:seed_type ==# v:t_number
    call s:init_genrand(l:rng, a:seed)
  else
    throw 'ES003: Invalid seed type ('.l:seed_type.'), expected list or number'
  endif
  return l:rng
endfunction

function! strager#random_mt19937#next_int32(rng)
  return s:genrand_int32(a:rng)
endfunction

function! strager#random_mt19937#next_integer(rng, minimum, maximum_plus_one)
  " FIXME(strager): This algorithm produces integers with an uneven
  " distribution.
  let l:width = a:maximum_plus_one - a:minimum
  return (strager#random_mt19937#next_int32(a:rng) % l:width) + a:minimum
endfunction

function! strager#random_mt19937#next_item_in_list(rng, items)
  let l:index = strager#random_mt19937#next_integer(a:rng, 0, len(a:items))
  return a:items[l:index]
endfunction

" Based on mt19937ar.c, downloaded December 12, 2018 from:
" http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/MT2002/emt19937ar.html
"
" Original copyright and license text follows:
"
" A C-program for MT19937, with initialization improved 2002/1/26.
" Coded by Takuji Nishimura and Makoto Matsumoto.
"
" Before using, initialize the state by using init_genrand(seed)
" or init_by_array(init_key, key_length).
"
" Copyright (C) 1997 - 2002, Makoto Matsumoto and Takuji Nishimura,
" All rights reserved.
"
" Redistribution and use in source and binary forms, with or without
" modification, are permitted provided that the following conditions
" are met:
"
"   1. Redistributions of source code must retain the above copyright
"      notice, this list of conditions and the following disclaimer.
"
"   2. Redistributions in binary form must reproduce the above copyright
"      notice, this list of conditions and the following disclaimer in the
"      documentation and/or other materials provided with the distribution.
"
"   3. The names of its contributors may not be used to endorse or promote
"      products derived from this software without specific prior written
"      permission.
"
" THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
" "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
" LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
" A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
" CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
" EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
" PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
" PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
" LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
" NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
" SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
"
"
" Any feedback is very welcome.
" http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/emt.html
" email: m-mat @ math.sci.hiroshima-u.ac.jp (remove space)

let s:n = 624
let s:m = 397
let s:matrix_a = 0x9908b0df
let s:upper_mask = 0x80000000
let s:lower_mask = 0x7fffffff
let s:mag01 = [0, s:matrix_a]

function! s:init_genrand(rng, s)
  let l:mt = a:rng._mt
  let l:mt[0] = and(a:s, 0xffffffff)
  let l:mti = 1
  while l:mti < s:n
    let l:mt[l:mti] = and(
      \ 1812433253 * xor(l:mt[l:mti - 1], l:mt[l:mti - 1] / 0x40000000) + l:mti,
      \ 0xffffffff,
    \ )
    let l:mti += 1
  endwhile
  let a:rng._mti = l:mti
endfunction

function! s:init_by_array(rng, init_key)
  let l:key_length = len(a:init_key)
  call s:init_genrand(a:rng, 19650218)
  let l:mt = a:rng._mt
  let l:i = 1
  let l:j = 0
  let l:k = s:n > l:key_length ? s:n : l:key_length
  while l:k !=# 0
    let l:mt[l:i] = and(
      \ xor(l:mt[l:i], xor(l:mt[l:i - 1], l:mt[l:i - 1] / 0x40000000) * 1664525)
        \ + a:init_key[l:j] + l:j,
      \ 0xffffffff,
    \ )
    let l:i += 1
    let l:j += 1
    if l:i >= s:n
      let l:mt[0] = l:mt[s:n - 1]
      let l:i = 1
    endif
    if l:j >= l:key_length
      let l:j = 0
    endif
    let l:k -= 1
  endwhile
  let l:k = s:n - 1
  while l:k !=# 0
    let l:mt[l:i] = and(
      \ xor(
        \ l:mt[l:i],
        \ xor(l:mt[l:i - 1], l:mt[l:i - 1] / 0x40000000) * 1566083941,
      \ ) - l:i,
      \ 0xffffffff,
    \ )
    let l:i += 1
    if l:i >= s:n
      let l:mt[0] = l:mt[s:n - 1]
      let l:i = 1
    endif
    let l:k -= 1
  endwhile
  let l:mt[0] = 0x80000000
endfunction

function! s:genrand_int32(rng)
  let l:mt = a:rng._mt
  let l:mti = a:rng._mti
  if l:mti >= s:n
    if l:mti ==# s:n + 1
      throw 'ES901: mt19937 state not initialized'
    endif
    let l:kk = 0
    while l:kk < s:n - s:m
      let l:y = or(
        \ and(l:mt[l:kk], s:upper_mask),
        \ and(l:mt[l:kk + 1], s:lower_mask),
      \ )
      let l:mt[l:kk] = xor(
        \ l:mt[l:kk + s:m],
        \ xor(l:y / 0x00000002, s:mag01[and(l:y, 0x1)]),
      \ )
      let l:kk += 1
    endwhile
    while l:kk < s:n - 1
      let l:y = or(
        \ and(l:mt[l:kk], s:upper_mask),
        \ and(l:mt[l:kk + 1], s:lower_mask),
      \ )
      let l:mt[l:kk] = xor(
        \ l:mt[l:kk + (s:m - s:n)],
        \ xor(l:y / 0x00000002, s:mag01[and(l:y, 0x1)]),
      \ )
      let l:kk += 1
    endwhile
    let l:y = or(and(l:mt[s:n - 1], s:upper_mask), and(l:mt[0], s:lower_mask))
    let l:mt[s:n - 1] = xor(
      \ l:mt[s:m - 1],
      \ xor(l:y / 0x00000002, s:mag01[and(l:y, 0x1)]),
    \ )
    let l:mti = 0
  endif
  let l:y = l:mt[l:mti]
  let l:mti += 1
  let l:y = xor(l:y, l:y / 0x00000800)
  let l:y = xor(l:y, and(l:y * 0x00000080, 0x9d2c5680))
  let l:y = xor(l:y, and(l:y * 0x00008000, 0xefc60000))
  let l:y = xor(l:y, l:y / 0x00040000)
  let a:rng._mti = l:mti
  return l:y
endfunction
