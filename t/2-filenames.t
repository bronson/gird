#!/bin/sh

test_description="Ensures we can handle bizarre file and directory names"

# These tests are important.
# Because Gird is used in archive environments with bizarrely-named files,
# it needs to get this right.

. ./sharness.sh

shellslash='\\'
if [ "$BASH_VERSINFO" == 3 ]; then
  # not sure why but this lets things work on Macs
  shellslash='\\\\'
fi

if command -v sha1sum >/dev/null 2>&1; then
  shacmd=sha1sum
elif command -v shasum >/dev/null 2>&1; then
  shacmd=shasum
else
  echo "shasum or sha1sum command not found!"
  exit
fi


check_evilname() {
  slash=
  if [[ "$evilname" = \\\\* ]]; then
    # a backslash at the start of the sha indicates the filename needs
    # to be unescaped: https://metacpan.org/release/Digest-SHA/source/shasum#L236
    slash="$shellslash"
  fi

  test_expect_success "Can process files named \"$evilname\"" "
    touch -- \"$evilname\" &&
    gird &&
    echo \"${slash}da39a3ee5e6b4b0d3255bfef95601890afd80709  $slash$evilname\" > expected &&
    test_cmp expected Girdsums &&
    $shacmd -c Girdsums &&
    rm -- expected \"$evilname\" Girdsums
  "

  test_expect_success "Recurses into directory named \"$evilname\"" "
    mkdir -- \"$evilname\" &&
    touch -- \"$evilname\"/hello &&
    gird &&
    echo \"da39a3ee5e6b4b0d3255bfef95601890afd80709  hello\" > expected &&
    (cd -- \"$evilname\" && test_cmp ../expected Girdsums) &&
    rm -r -- \"$evilname\" Girdsums expected
  "

  test_expect_success "Runs on directory named \"$evilname\"" "
    mkdir -- \"$evilname\" &&
    touch -- \"$evilname\"/hello &&
    gird -- \"$evilname\" &&
    echo \"da39a3ee5e6b4b0d3255bfef95601890afd80709  hello\" > expected &&
    (cd -- \"$evilname\" && test_cmp ../expected Girdsums) &&
    rm -r -- \"$evilname\" expected
  "
}



for evilname in \
  " a b   c " \
  "'a'" \
  '\"a\"' \
  '\\\"' \
  "\\\'" \
  '\$f' \
  '\\\$f' \
  'a;b>c|d&&e' \
  'e()f#g!h@i?' \
  '$' '*' '&' '<' '>' ';' \
; do
  check_evilname "$evilname"
done

if [ "$shacmd" -ne "sha1sum" ]; then
  # sha1sum will fail these tests. It doesn't offer '--'
  # or any way for it to distinguish filenames from arguments.
  for evilname in \
    '-h' \
    '--help' \
    '--' \
  ; do
    check_evilname "$evilname"
  done
fi

test_done

# random thoughts:
# Can't use a heredoc to remove the need for the `expected` file.
# It works when running directly, fails when running in `prove`.
#     diff -u <(echo \"da39a3ee5e6b4b0d3255bfef95601890afd80709  $evil\") Girdsums &&
# Ah, the issue appears to be the process substitution. See the 'Running in empty dir' test.
