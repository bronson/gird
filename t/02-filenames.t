#!/bin/sh

test_description="Ensures we can handle bizarre file and directory names"

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
#   echo \"\\da39a3ee5e6b4b0d3255bfef95601890afd80709  \\\\\\\\b\" > tt &&
#   test_cmp tt Girdsums &&
#   rm tt \"$filename\" Girdsums
# "

  # '\$f' \
  # '\\\$f' \
  # '\\\"' "\\\'" \

for evilname in \
  " a b   c " \
  "'a'" \
  '\"a\"' \
  'a;b>c|d&&e' \
  'e()f#g!h@i?' \
  '$' '*' '&' '<' '>' ';' \
  '-h' \
  '--help' \
; do
  test_expect_success "Can process files named \"$evilname\"" "
    touch -- \"$evilname\" &&
    gird &&
    echo \"da39a3ee5e6b4b0d3255bfef95601890afd80709  $evilname\" > tt &&
    test_cmp tt Girdsums &&
    rm -- tt \"$evilname\" Girdsums &&
    echo LISTING:
    find .
    echo DONE
  "

  test_expect_success "Recurses into directory named \"$evilname\"" "
    case \"$evilname\" in
    \\\"*) : ;;  # can't currently recurse over directories with dblquote in their names
    *)
      mkdir -- \"$evilname\" &&
      touch -- \"$evilname\"/hello &&
      gird &&
      echo \"da39a3ee5e6b4b0d3255bfef95601890afd80709  hello\" > tt &&
      (cd -- \"$evilname\" && test_cmp ../tt Girdsums) &&
      rm -r -- \"$evilname\" Girdsums tt
    esac
  "

  test_expect_success "Runs on directory named \"$evilname\"" "
    case \"$evilname\" in
    -*|\\\"*) : ;;  # gird doesn't support directories with leading hyphens on the command line
    *)
      mkdir -- \"$evilname\" &&
      touch -- \"$evilname\"/hello &&
      gird \"$evilname\" &&
      echo \"da39a3ee5e6b4b0d3255bfef95601890afd80709  hello\" > tt &&
      (cd -- \"$evilname\" && test_cmp ../tt Girdsums) &&
      rm -r -- \"$evilname\" tt
      ;;
    esac
  "
done

test_done

# random thoughts:
# Can't use a heredoc to remove the need for the tt file.
# It works when running directly, fails when running in `prove`.
#     diff -u <(echo \"da39a3ee5e6b4b0d3255bfef95601890afd80709  $evil\") Girdsums &&
# Ah, the issue appears to be the process substitution. See the 'Running in empty dir' test.
