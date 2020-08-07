#!/bin/sh

test_description="Ensures the busywork gets done"

. sharness.sh

test_expect_success "Can retrieve the current version" "
  gird --version > stdout &&
  grep -q '^Gird [0-9.]*$' stdout &&
  [ ! -e Girdsums ] &&
  rm stdout
"

# ensures the help printed by the command is the same as the
# help at the top of the readme file.
test_expect_success "Can retrieve help" "
  gird --help > stdout &&
  cat "$SHARNESS_TEST_DIRECTORY"/../README.md |
    sed -n '/\`\`\`help/,/\`\`\`/p' | sed -e 1d -e '\$d' > helptext &&
  test_cmp helptext stdout &&
  [ ! -e Girdsums ] &&
  rm helptext stdout
"

test_done
