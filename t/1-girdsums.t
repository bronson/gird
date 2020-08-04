#!/bin/sh

test_description="Ensures recursive checksumming works"

. sharness.sh

test_expect_success "Simple recursive checksum" "
  cp -r "$SHARNESS_TEST_DIRECTORY/fixtures/test-tree" . &&
  find . -name Girdsums -delete &&
  gird test-tree &&
  test_cmp "$SHARNESS_TEST_DIRECTORY/fixtures/test-tree/Girdsums" test-tree/Girdsums &&
  test_cmp "$SHARNESS_TEST_DIRECTORY/fixtures/test-tree/dir/Girdsums" test-tree/dir/Girdsums &&
  test_cmp "$SHARNESS_TEST_DIRECTORY/fixtures/test-tree/dir2/Girdsums" test-tree/dir2/Girdsums &&
  test_cmp "$SHARNESS_TEST_DIRECTORY/fixtures/test-tree/.hiddendir/Girdsums" test-tree/.hiddendir/Girdsums &&
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

# runs all directories specified on the command line
test_expect_success "Multiple directories can be specified" "
  mkdir a b c &&
  touch {a..c}/Girdsums &&
  gird a b c >stdout &&
  echo verifying a >expected &&
  echo verifying b >>expected &&
  echo verifying c >>expected &&
  test_cmp expected stdout &&
  rm -r a b c expected stdout
"

# gird used to try a, b, and c, even if a aborted.
test_expect_success "Abort prevents further directories from being checked" "
  test_expect_code 1 bash -c 'gird a b c 2>stderr' &&
  echo 'find: a: No such file or directory' > expected &&
  test_cmp expected stderr &&
  rm expected stderr
"

# a doesn't exist, b is missing a Girdsums, c has an incorrect Girdsums, d doesn't exist
test_expect_success "User can force processing to continue" "
  mkdir b c &&
  touch b/testfile c/testfile &&
  echo '03cfd743661f07975fa2f1220c5194cbaff48451  file1' > c/Girdsums && # incorrect sum
  test_expect_code 1 bash -c 'gird --verify --continue a b c d 2>stderr' &&
  test_cmp "$SHARNESS_TEST_DIRECTORY/fixtures/example-stderr.txt" stderr &&
  rm -r b c stderr
"

test_expect_success "Processes hidden files" "
  touch .hidden &&
  gird &&
  echo \"da39a3ee5e6b4b0d3255bfef95601890afd80709  .hidden\" > tt &&
  test_cmp tt Girdsums &&
  rm .hidden tt Girdsums
"

test_expect_success "Processes hidden directories" "
  mkdir .hidden &&
  touch .hidden/hi &&
  gird &&
  echo \"da39a3ee5e6b4b0d3255bfef95601890afd80709  hi\" > tt &&
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

test_expect_success "Handles multiple arguments" "
  mkdir yesdir1 yesdir2 nodir &&
  gird yesdir1 yesdir2 &&
  [ -f yesdir1/Girdsums ] && [ -f yesdir2/Girdsums ] &&
  [ ! -e nodir/Girdsums ] &&
  rm -r yesdir1 yesdir2 nodir
"

# Ensure we do nothing if passed a file. Silence is acceptable.
test_expect_success "Fails when passed a file" "
  touch afile &&
  gird afile &&
  [ ! -e Girdsums ] &&
  rm afile
"

# print a warning if we don't recognize an argument
# (if the user wants to gird a directory starting with a hyphen,
# they can just cd into that directory and run `gird`)
test_expect_success "Warns about unrecognized arguments" "
  touch afile &&
  test_expect_code 1 gird --what 2>stderr &&
  echo 'unknown option: --what' > expected &&
  test_cmp expected stderr &&
  [ ! -e Girdsums ] &&
  rm afile expected stderr
"

# the `find:` at the beginning of the error message is unfortunate but meh
test_expect_success "Aborts if directory doesn't exist" "
  test_expect_code 1 bash -c 'gird noexisty 2>stderr'
  echo 'find: noexisty: No such file or directory' > expected &&
  test_cmp expected stderr &&
  rm expected stderr
"

# starting in a directory without a Girdsums puts us into init mode
# so a subdirectory with a Girdsums file should be an error
test_expect_success "Correctly selects verify starting mode" "
  mkdir -p testdir/testdir &&
  touch testdir/Girdsums &&
  test_expect_code 1 bash -c 'gird testdir 2>stderr' &&
  echo 'testdir/testdir: missing Girdsums file' > expected &&
  test_cmp expected stderr &&
  rm -r testdir expected stderr
"

test_expect_success "Correctly selects init starting mode" "
  mkdir -p testdir/testdir &&
  touch testdir/testdir/Girdsums &&
  test_expect_code 1 bash -c 'gird testdir 2>stderr'
  echo 'testdir/testdir: existing Girdsums file' > expected &&
  test_cmp expected stderr &&
  rm -r testdir expected stderr
"

# fill in verifydir with already-existing Girdfiles
test_expect_success "Selects the correct starting mode for each dir" "
  mkdir -p initdir/testdir verifydir/testdir ignoredir/testdir &&
  touch verifydir/testdir/Girdsums &&
  echo 'da39a3ee5e6b4b0d3255bfef95601890afd80709  testdir/Girdsums' > verifydir/Girdsums &&
  gird initdir verifydir > stdout &&
  echo initializing initdir/testdir > expected
  echo initializing initdir >> expected
  echo verifying verifydir/testdir >> expected
  echo verifying verifydir >> expected
  test_cmp expected stdout &&
  test_cmp initdir/Girdsums verifydir/Girdsums &&
  [ ! -f ignoredir/Girdsums ] &&
  rm -r initdir verifydir ignoredir expected stdout
"

test_expect_success "Girdsums files are created in hierarchy" "
  mkdir -p a/a/a/a/a/a/a &&
  touch a/a/a/a/a/a/a/emptyfile &&
  gird --init &&
  echo 'da39a3ee5e6b4b0d3255bfef95601890afd80709  emptyfile' > expected &&
  test_cmp expected a/a/a/a/a/a/a/Girdsums &&
  echo '92a76836c493f58229546705e0312a4d9f87da7a  a/Girdsums' > expected &&
  test_cmp expected Girdsums &&
  rm -r expected a Girdsums
"

test_expect_success "Girdsums files are created in hierarchy" "
  mkdir -p a/a &&
  gird --init &&
  [ -z \"\$(cat a/a/Girdsums)\" ] &&
  echo '99929660309feded68338fbdb5c729a20be2d0b4  a/Girdsums' > expected &&
  test_cmp expected Girdsums &&
  rm -r expected a Girdsums
"

# test_expect_success "Can reset the entire directory" "
#   mkdir -p badgird nogird goodgird &&
#   touch badgird/Girdsums badgird/file3 nogird/file3 goodgird/file3 &&
#   echo '03cfd743661f07975fa2f1220c5194cbaff48451  file3' > badgird/Girdsums &&
#   echo 'da39a3ee5e6b4b0d3255bfef95601890afd80709  file3' > goodgird/Girdsums &&
#   test_pause &&
#   gird --reset . &&
#   rm -r badgird nogird goodgird
# "

test_done
