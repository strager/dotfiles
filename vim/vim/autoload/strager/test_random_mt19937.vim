function Test_samples_match_reference_implementation() abort
  let l:seed = [0x0123, 0x0234, 0x0345, 0x0456]
  let l:rng = strager#random_mt19937#make_generator(l:seed)
  let l:index = 0
  for l:expected_sample in strager#test_random_mt19937_data#genrand_int32_reference_samples()
    let l:actual_sample = strager#random_mt19937#next_int32(l:rng)
    call assert_equal(
      \ l:expected_sample,
      \ l:actual_sample,
      \ printf('Index %d', l:index),
    \ )
    if v:errors !=# []
      break
    endif
    let l:index += 1
  endfor
endfunction

function Test_matches_cxx11_standard() abort
  let l:rng = strager#random_mt19937#make_generator(5489)
  let l:i = 0
  while l:i < 10000
    let l:sample = strager#random_mt19937#next_int32(l:rng)
    let l:i += 1
  endwhile
  call assert_equal(4123659995, l:sample)
endfunction

function Test_random_integer_returns_integers_in_range() abort
  for [l:minimum, l:maximum_plus_one] in [[0, 1], [0, 42], [10000, 20000]]
    let l:rng = strager#random_mt19937#make_generator(5489)
    let l:i = 0
    while l:i < 1000
      let l:sample = strager#random_mt19937#next_integer(
        \ l:rng,
        \ l:minimum,
        \ l:maximum_plus_one,
      \ )
      let l:message = printf(
        \ 'Sample %d should be in range [%d, %d)',
        \ l:sample,
        \ l:minimum,
        \ l:maximum_plus_one,
      \ )
      call assert_true(l:sample >= l:minimum, l:message)
      call assert_true(l:sample < l:maximum_plus_one, l:message)
      if v:errors !=# []
        break
      endif
      let l:i += 1
    endwhile
  endfor
endfunction

function Test_random_integer_returns_integers_with_reasonable_distribution() abort
  let l:minimum = 10
  let l:maximum_plus_one = 42
  let l:width = l:maximum_plus_one - l:minimum
  call assert_true(l:width > 1)

  let l:histogram = repeat([0], l:width)
  let l:rng = strager#random_mt19937#make_generator(5489)
  let l:i = 0
  while l:i < l:width * 10
    let l:sample = strager#random_mt19937#next_integer(
      \ l:rng,
      \ l:minimum,
      \ l:maximum_plus_one,
    \ )
    let l:histogram[l:sample - l:minimum] += 1
    let l:i += 1
  endwhile

  let l:integer = l:minimum
  while l:integer < l:maximum_plus_one
    let l:count = l:histogram[l:integer - l:minimum]
    call assert_true(l:count > 0, printf(
      \ 'Integer %d should have been sampled at least once',
      \ l:integer,
    \ ))
    let l:integer += 1
  endwhile
endfunction

call strager#test#run_all_tests()
