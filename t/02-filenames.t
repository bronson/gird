#!/bin/sh

test_description="Ensures recursive checksumming works"

. sharness.sh

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
# Ah, the issue appears to be the process substitution. See the 'Running in empty dir' test.
test_expect_success "Handles evil filename characters" "
  touch \"$evil\" &&
  gird &&
  echo \"da39a3ee5e6b4b0d3255bfef95601890afd80709  ./$evil\" > tt &&
  test_cmp tt Girdsums &&
  rm tt \"$evil\" Girdsums
"

# TODO: this still fails for filenames with double quotes in their names
  # '\"a\"' \
# need to figoure out an xargs workaround.

for dirname in \
  " a b   c " \
  "'a'" \
  'a;b>c|d&&e\\$f()g!h' \
; do
  test_expect_success "Recurses into directory named \"$dirname\"" "
    mkdir \"$dirname\" &&
    touch \"$dirname\"/hello &&
    gird &&
    echo \"da39a3ee5e6b4b0d3255bfef95601890afd80709  ./hello\" > tt &&
    test_cmp tt \"$dirname\"/Girdsums &&
    rm -r \"$dirname\" Girdsums tt
  "

  test_expect_success "Runs on directory named \"$dirname\"" "
    mkdir \"$dirname\" &&
    touch \"$dirname\"/hello &&
    gird \"$dirname\" &&
    echo \"da39a3ee5e6b4b0d3255bfef95601890afd80709  ./hello\" > tt &&
    test_cmp tt \"$dirname\"/Girdsums &&
    rm -r \"$dirname\" tt
  "
done

test_done
