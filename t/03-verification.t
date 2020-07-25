#!/bin/sh

test_description="Ensures gird can verify its own output"

. sharness.sh

test_expect_success "Aborts when it finds an inprogress file" "
  touch Girdsums.inprogress &&
  touch empty &&
  test_expect_code 1 gird &&
  [ ! -e Girdsums ] &&
  rm Girdsums.inprogress empty
"

test_expect_success "Silent success when it finds a correct Girdfile" "
  echo a > testfile &&
  gird &&     # generate
  gird &&     # verify
  rm Girdsums testfile
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
  test_expect_code 1 gird --verify &&
  [ \"$(find .)\" == '.' ]
"

test_expect_success "Rejects a girdfile when creating" "
  touch Girdsums &&
  test_expect_code 1 gird --create &&
  rm Girdsums
"

test_expect_success "Girds Girdsum files one directory deeper" "
  cp -r "$SHARNESS_TEST_DIRECTORY/fixtures/deep-tree" . &&
  gird --create && # test both
  gird --verify &&
  grep deep-tree/Girdsums Girdsums &&
  grep dirone/Girdsums deep-tree/Girdsums &&
  rm -r deep-tree
"

test_done
