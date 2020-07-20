#!/bin/sh

test_description="Ensures recursive checksumming works"

. sharness.sh

test_expect_success "Simple recursive checksum" "
  cp -r "$SHARNESS_TEST_DIRECTORY/fixtures/test-tree" . &&
  gird test-tree &&
  test_cmp "$SHARNESS_TEST_DIRECTORY/fixtures/test-tree/.sha1sums" test-tree/.sha1sums &&
  test_cmp "$SHARNESS_TEST_DIRECTORY/fixtures/test-tree/dir/.sha1sums" test-tree/dir/.sha1sums &&
  test_cmp "$SHARNESS_TEST_DIRECTORY/fixtures/test-tree/dir2/.sha1sums" test-tree/dir2/.sha1sums
"

test_done
