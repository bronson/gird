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
  echo a > testfile &&
  gird &&
  echo b > testfile
  test_expect_code 1 gird &&
  rm Girdsums testfile
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

test_done
