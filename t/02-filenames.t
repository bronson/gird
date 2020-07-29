#!/bin/sh

test_description="Ensures we can handle bizarre file and directory names"

# These tests are very important.
# Because Gird is used in archive environments with a few
# bizarrely-named files, it needs to get this right.

. sharness.sh

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

  slash= prove=
  if [[ "$evilname" = \\\\* ]]; then
    # a backslash at the start of the sha indicates the filename needs
    # to be unescaped: https://metacpan.org/release/Digest-SHA/source/shasum#L236
    slash='\\'

    prove="$slash"
    if [ -n "$VERSIONER_PERL_VERSION" ]; then
      # we're running under Prove. For some reason Prove requires a double-escape.
      # I'm not sure if this is a bug in my code, sharness, or prove.
      # (if this var isn't reliable, there are some other env vars only seen under prove:
      #     HARNESS_ACTIVE,HARNESS_VERSION,TAP_VERSION,PERL5LIB,PERL_*)
      prove="$slash$slash"
    fi
  fi

  test_expect_success "Can process files named \"$evilname\"" "
    touch -- \"$evilname\" &&
    gird &&
    echo \"${slash}da39a3ee5e6b4b0d3255bfef95601890afd80709  $prove$evilname\" > expected &&
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
