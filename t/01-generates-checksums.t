#!/bin/sh

test_description="Ensures recursive checksumming works"

. sharness.sh

test_expect_success "Simple recursive checksum" "
  cp -r "$SHARNESS_TEST_DIRECTORY/fixtures/test-tree" . &&
  gird test-tree &&
  test_cmp "$SHARNESS_TEST_DIRECTORY/fixtures/test-tree/Girdsums" test-tree/Girdsums &&
  test_cmp "$SHARNESS_TEST_DIRECTORY/fixtures/test-tree/dir/Girdsums" test-tree/dir/Girdsums &&
  test_cmp "$SHARNESS_TEST_DIRECTORY/fixtures/test-tree/dir2/Girdsums" test-tree/dir2/Girdsums &&
  rm -r test-tree
"

# It appears that heredocs are fundamentally incompatible with sharness.
#     test_cmp <(echo -n) Girdsums
test_expect_success "Running in empty dir" "
  gird &&
  >tt &&
  test_cmp tt Girdsums &&
  rm tt Girdsums
"

test_expect_success "Processes hidden files" "
  touch .hidden &&
  gird &&
  echo \"da39a3ee5e6b4b0d3255bfef95601890afd80709  ./.hidden\" > tt &&
  test_cmp tt Girdsums &&
  rm .hidden tt Girdsums
"

test_expect_success "Process hidden directories" "
  mkdir .hidden &&
  touch .hidden/hi &&
  gird &&
  echo \"da39a3ee5e6b4b0d3255bfef95601890afd80709  ./hi\" > tt &&
  test_cmp tt .hidden/Girdsums &&
  rm -r .hidden tt Girdsums
"

test_expect_success "Skips garbage files" "
  touch .DS_Store &&
  gird &&
  touch empty_file &&
  test_cmp empty_file Girdsums &&
  rm empty_file Girdsums .DS_Store
"

test_done
