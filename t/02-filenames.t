#!/bin/sh

test_description="Ensures we can handle bizarre file and directory names"

# These tests are very important.
# Because Gird is used in archive environments with a few
# bizarrely-named files, it needs to get this right.

. sharness.sh

# Probably need to disable this test on Windows
# TODO: yikes, is this a sharness problem?
#    This test works when run directly but not when run by `prove`.
#    The \\\\\\\\ works but it can't possibly be intentional.
#
# filename="\b"
# test_expect_success "Handles backslashes in filenames" "
#   touch \"$filename\" &&
#   gird &&
#   echo \"\\da39a3ee5e6b4b0d3255bfef95601890afd80709  \\\\\\\\b\" > expected &&
#   test_cmp expected Girdsums &&
#   rm expected \"$filename\" Girdsums
# "

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
  '-h' \
  '--help' \
; do

  # a backslash at the start of the sha indicates the filename needs
  # to be unescaped: https://metacpan.org/release/Digest-SHA/source/shasum#L236
  slash= ; [[ "$evilname" = \\\\* ]] && slash='\\'

  test_expect_success "Can process files named \"$evilname\"" "
    touch -- \"$evilname\" &&
    gird &&
    echo \"${slash}da39a3ee5e6b4b0d3255bfef95601890afd80709  $slash$evilname\" > expected &&
    test_cmp expected Girdsums &&
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
    case \"$evilname\" in
    -*) : ;;  # gird doesn't support naming directories with leading hyphens on the command line
    *)
      mkdir -- \"$evilname\" &&
      touch -- \"$evilname\"/hello &&
      gird \"$evilname\" &&
      echo \"da39a3ee5e6b4b0d3255bfef95601890afd80709  hello\" > expected &&
      (cd -- \"$evilname\" && test_cmp ../expected Girdsums) &&
      rm -r -- \"$evilname\" expected
      ;;
    esac
  "
done

test_done

# random thoughts:
# Can't use a heredoc to remove the need for the `expected` file.
# It works when running directly, fails when running in `prove`.
#     diff -u <(echo \"da39a3ee5e6b4b0d3255bfef95601890afd80709  $evil\") Girdsums &&
# Ah, the issue appears to be the process substitution. See the 'Running in empty dir' test.
