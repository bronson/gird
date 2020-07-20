#!/bin/sh

test_description="Ensures recursive checksumming works"

. sharness.sh

test_expect_success "Simple recursive checksum" "
  cp -r "$SHARNESS_TEST_DIRECTORY/fixtures/test-tree" . &&
  gird test-tree &&
  test_cmp "$SHARNESS_TEST_DIRECTORY/fixtures/test-tree/Girdsums" test-tree/Girdsums &&
  test_cmp "$SHARNESS_TEST_DIRECTORY/fixtures/test-tree/dir/Girdsums" test-tree/dir/Girdsums &&
  test_cmp "$SHARNESS_TEST_DIRECTORY/fixtures/test-tree/dir2/Girdsums" test-tree/dir2/Girdsums
"

test_done
