#!/bin/sh

test_description="Ensures the busywork gets done"

. sharness.sh

test_expect_success "Can retrieve the current version" "
  gird --version > stdout &&
  grep -q '^Gird [0-9.]*$' stdout &&
  [ ! -e Girdsums ] &&
  rm stdout
"

test_done
