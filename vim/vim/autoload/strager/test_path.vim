function! Test_join_paths()
  " Join with an empty string.
  call assert_equal('', strager#path#join(['', '']))
  call assert_equal('.', strager#path#join(['.', '']))
  call assert_equal('/', strager#path#join(['', '/']))
  call assert_equal('/', strager#path#join(['/', '']))
  call assert_equal('a', strager#path#join(['', 'a']))
  call assert_equal('a', strager#path#join(['a', '']))
  call assert_equal('a/', strager#path#join(['', 'a/']))
  call assert_equal('a/', strager#path#join(['a/', '']))
  call assert_equal('a//', strager#path#join(['', 'a//']))
  call assert_equal('a//', strager#path#join(['a//', '']))

  " Join an absolute path with a relative path.
  call assert_equal('//a/b/c', strager#path#join(['//', 'a/b/c']))
  call assert_equal('/a//b/c', strager#path#join(['/a//', 'b/c']))
  call assert_equal('/a/b//c', strager#path#join(['/a/b//', 'c']))
  call assert_equal('/a/b/c', strager#path#join(['/', 'a/b/c']))
  call assert_equal('/a/b/c', strager#path#join(['/a', 'b/c']))
  call assert_equal('/a/b/c', strager#path#join(['/a/', 'b/c']))
  call assert_equal('/a/b/c', strager#path#join(['/a/b', 'c']))
  call assert_equal('/a/b/c', strager#path#join(['/a/b/', 'c']))

  " Join a relative path with a relative path.
  call assert_equal('a/b//c', strager#path#join(['a/b//', 'c']))
  call assert_equal('a/b/c', strager#path#join(['a', 'b/c']))
  call assert_equal('a/b/c', strager#path#join(['a/', 'b/c']))
  call assert_equal('a/b/c', strager#path#join(['a/b', 'c']))
  call assert_equal('a/b/c', strager#path#join(['a/b/', 'c']))

  " Join a relative path with an absolute path.
  call assert_equal('/b/c', strager#path#join(['a', '/b/c']))
  call assert_equal('/b/c', strager#path#join(['a/', '/b/c']))
  call assert_equal('/b/c', strager#path#join(['a//', '/b/c']))
  call assert_equal('/c', strager#path#join(['a/b', '/c']))
  call assert_equal('/c', strager#path#join(['a/b/', '/c']))
  call assert_equal('/c', strager#path#join(['a/b//', '/c']))
endfunction

call strager#test#run_all_tests()
