#!/bin/sh

test_description="Ensures recursive checksumming works"

. sharness.sh

test_expect_success "Simple recursive checksum" "
  cp -r "$SHARNESS_TEST_DIRECTORY/fixtures/test-tree" . &&
  gird test-tree &&
  test_cmp "$SHARNESS_TEST_DIRECTORY/fixtures/test-tree/Girdsums" test-tree/Girdsums &&
  test_cmp "$SHARNESS_TEST_DIRECTORY/fixtures/test-tree/dir/Girdsums" test-tree/dir/Girdsums &&
  test_cmp "$SHARNESS_TEST_DIRECTORY/fixtures/test-tree/dir2/Girdsums" test-tree/dir2/Girdsums &&
  rm -rf test-tree
"

filename=" a b   c "
test_expect_success "Handles spaces in filenames" "
  touch \"$filename\" &&
  gird &&
  echo \"da39a3ee5e6b4b0d3255bfef95601890afd80709  ./$filename\" > tt &&
  test_cmp tt Girdsums &&
  rm tt \"$filename\" Girdsums
"

# Probably need to disable this test on Windows
# TODO: yikes, is this a sharness problem?
#    This test works when run directly but not when run by `prove`.
#    The \\\\\\\\ works but it can't possibly be intentional.
#
# filename="\b"
# test_expect_success "Handles backslashes in filenames" "
#   touch \"$filename\" &&
#   gird &&
#   echo \"\\da39a3ee5e6b4b0d3255bfef95601890afd80709  ./\\\\\\\\b\" > tt &&
#   test_cmp tt Girdsums &&
#   rm tt \"$filename\" Girdsums
# "

filename="'a'"
test_expect_success "Handles single quotes in filenames" "
  touch \"$filename\" &&
  gird &&
  echo \"da39a3ee5e6b4b0d3255bfef95601890afd80709  ./$filename\" > tt &&
  test_cmp tt Girdsums &&
  rm tt \"$filename\" Girdsums
"

filename='\"a\"'
test_expect_success "Handles double quotes in filenames" "
  touch \"$filename\" &&
  gird &&
  echo \"da39a3ee5e6b4b0d3255bfef95601890afd80709  ./$filename\" > tt &&
  test_cmp tt Girdsums &&
  rm tt \"$filename\" Girdsums
"

evil='a;b>c|d&&e\$f()g!h'
# Can't use a heredoc to remove the need for the tt file.
# It works when running directly, fails when running in `prove`.
#     diff -u <(echo \"da39a3ee5e6b4b0d3255bfef95601890afd80709  ./$evil\") Girdsums &&
test_expect_success "Handles evil filename characters" "
  touch \"$evil\" &&
  gird &&
  echo \"da39a3ee5e6b4b0d3255bfef95601890afd80709  ./$evil\" > tt &&
  test_cmp tt Girdsums &&
  rm tt \"$evil\" Girdsums
"

test_done
