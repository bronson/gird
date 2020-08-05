#!/bin/sh

test_description="Ensures the reset feature works"

. sharness.sh

# ensures a simple reset works
test_expect_success "Can reset a single path" "
  mkdir workdir &&
  touch workdir/emptyfile &&
  gird --init workdir &&
  echo 'hi' > workdir/emptyfile
  test_expect_code 1 gird --verify workdir &&
  gird --reset workdir &&
  gird --verify workdir &&
  rm -r workdir
"

# ensures that reset only affects the directories named on the command line and their parents
# (all of a gets reset, all of b gets ignored, ca gets reset but caa doesn't)
test_expect_success "Can reset a hierarchy" "
  mkdir -p tt/a/aa/aaa tt/b/ba tt/c/ca/caa &&
  touch tt/a/aa/aaa/emptyfile tt/b/ba/emptyfile tt/c/ca/emptyfile tt/c/ca/caa/emptyfile &&
  gird --init tt &&
  echo '41873a4d1fe87262c75c0ed2dbfd3c4d5b82a57e  a/Girdsums' > example &&
  echo 'c9d2f1d3d408be7f1bf6a34b0532b6d3dac27816  b/Girdsums' >> example &&
  echo '57fb24a07fa5d18ca86f3268a552817dc175e874  c/Girdsums' >> example &&
  test_cmp example tt/Girdsums &&
  echo 'hi' > tt/a/aa/aaa/emptyfile &&  # reset these
  echo 'hi' > tt/c/ca/emptyfile &&
  echo 'hi' > tt/b/ba/emptyfile &&      # don't reset these
  echo 'hi' > tt/c/ca/caa/emptyfile &&
  gird --reset --abort tt/a/aa/aaa tt/c/ca &&
  echo '1dd97b158845477b9dd37beaeb99841097083134  a/Girdsums' > example &&
  echo 'c9d2f1d3d408be7f1bf6a34b0532b6d3dac27816  b/Girdsums' >> example &&
  echo 'cb8bfa251b732edc5cd535b0ac6a10f9088e627c  c/Girdsums' >> example &&
  test_cmp example tt/Girdsums &&
  gird --verify tt/a &&                                         # a has been reset
  test_expect_code 1 gird --verify tt/b 2>stderr &&             # b hasn't been reset
  test_expect_code 1 gird --verify --continue tt/c 2>stderr &&  # ca is valid, caa isn't
  echo 'tt/c/ca/caa: gird verification failed:' > example &&
  echo '-da39a3ee5e6b4b0d3255bfef95601890afd80709  emptyfile' >> example &&
  echo '+55ca6286e3e4f4fba5d0448333fa99fc5a404a73  emptyfile' >> example &&
  test_cmp example stderr &&
  rm -r tt example stderr
"

# can abort when path isn't found
test_expect_success "Fails OK when dir doesn't exist" "
  test_expect_code 1 gird --reset workdir 2>stderr &&
  echo 'workdir does not exist' > expected &&
  test_cmp expected stderr &&
  rm expected stderr
"

# can continue when path isn't found
test_expect_success "Remembers error code" "
  mkdir b &&
  test_expect_code 1 gird --reset a b >stdout 2>stderr &&
  echo 'a does not exist' > expected &&
  test_cmp expected stderr &&
  echo 'resetting b' > expected &&
  test_cmp expected stdout &&
  rm expected stdout stderr
"

test_done
