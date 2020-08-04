#!/bin/sh

test_description="Ensures gird can verify its own output"

. sharness.sh

test_expect_success "Aborts when it finds an inprogress file" "
  touch Girdsums-inprogress &&
  touch empty &&
  test_expect_code 1 gird 2>stderr &&
  echo '.: Girdsums-inprogress already exists. Is another Gird running? Exiting.' > expected &&
  test_cmp expected stderr &&
  [ ! -e Girdsums ] &&
  rm expected stderr Girdsums-inprogress empty
"

test_expect_success "Silent success when it finds a correct Girdfile" "
  mkdir testdir &&
  echo a > testdir/testfile &&
  gird testdir > stdout1 &&  # initialize
  gird testdir > stdout2 &&  # verify
  echo 'initializing testdir' > expected &&
  test_cmp expected stdout1 &&
  echo 'verifying testdir' > expected &&
  test_cmp expected stdout2 &&
  rm -r testdir stdout1 stdout2 expected
"

test_expect_success "Aborts when it finds an incorrect Girdfile" "
  mkdir workdir &&
  echo a > workdir/testfile &&
  gird workdir &&
  echo b > workdir/testfile &&
  test_expect_code 1 gird workdir 2>stderr &&
  echo 'workdir: gird verification failed:' > expected &&
  echo '-3f786850e387550fdab836ed7e6dc881de23001b  testfile' >> expected &&
  echo '+89e6c98d92887913cadf06b2adb97f26cde4849b  testfile' >> expected &&
  test_cmp expected stderr &&
  rm -r workdir expected stderr
"

test_expect_success "Requires a girdfile when verifying" "
  [ \"$(find .)\" == '.' ] &&
  test_expect_code 1 gird --verify 2>stderr &&
  echo '.: missing Girdsums file' > expected &&
  test_cmp expected stderr &&
  rm expected stderr &&
  [ \"$(find .)\" == '.' ]
"

test_expect_success "Rejects a girdfile when creating" "
  touch Girdsums &&
  test_expect_code 1 gird --init 2>stderr &&
  echo '.: existing Girdsums file' > expected &&
  test_cmp expected stderr &&
  rm Girdsums
"

test_expect_success "Girds Girdsum files one directory deeper" "
  cp -r "$SHARNESS_TEST_DIRECTORY/fixtures/deep-tree" . &&
  gird --init . && # test both
  gird --verify . &&
  grep deep-tree/Girdsums Girdsums &&
  grep dirone/Girdsums deep-tree/Girdsums &&
  shasum -c Girdsums &&
  rm -r deep-tree
"

# b is processed last, and produces no error.
# but since a has an error, the command must return an error.
test_expect_success "If it finds both error and valid Girdsums files, returns an error" "
  mkdir a b &&
  touch a/mt b/mt &&
  gird --init a b &&
  echo hi > a/mt &&
  test_expect_code 1 gird --verify --continue a b > output 2>&1 &&
  echo 'verifying a' > expected &&
  echo 'a: gird verification failed:' >> expected &&
  echo '-da39a3ee5e6b4b0d3255bfef95601890afd80709  mt' >> expected &&
  echo '+55ca6286e3e4f4fba5d0448333fa99fc5a404a73  mt' >> expected &&
  echo 'verifying b' >> expected &&
  test_cmp expected output &&
  rm -r a b output
"

test_done
