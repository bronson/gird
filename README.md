# Gird

When you're storing files for a long time, tiny corruptions can add up.
Gird adds checksums next to each file so those corruptions can be found
soon after they happen instead of years later by accident.

Gird generates hashes for every file in a directory and stores them in
a file named Girdsums. All subdirectories are processed too.
Later, Gird can check these hashes and verify that the contents of
the files are identical to when they were first girded.

## Installation

Copy the `gird` file somewhere on your path.

## Testing

The tests use [Sharness](https://github.com/chriscool/sharness). To run them:

```bash
cd t
make
```

## Usage

To generate checksums:

```bash
gird Photos
```

This creates a Girdsums file containing the SHA for each file in Photos.
It then operates recursively on all subdirectories, sorted alphabetically.

To verify checksums, just run the command again. Since there's now a Girdsums file in that directory, Gird knows it should verify the Girdsums files rather than creating them.

```bash
gird Photos
```

Or you can be explicit so Gird will abort if it doesn't find existing checksums:

```bash
gird --verify Photos
```

Running 'gird' without arguments starts in the current directory, identical to typing `gird .`

```bash
gird
```

Gird processes hidden files and directories and skips files named `.DS_Store`.

## Girdsums File

Girdsums stores the SHA checksums of each file in the current directory (including hidden files, but ignoring `.DS_Store`) in the `shasum` command's native format.

In addition to using `gird --verify`, you can check Girdsums files by passing them to shasum:

```bash
shasum -c Girdsums
```

## Motivation

I'm backing up my files to a number of places: local drive, offsite USB drive, and cloud.
If those backups ever disagree, gird allows me to see which file is correct and
which one is corrupt.

A story... In the 1990s I moved my mp3 collection (painstakingly ripped from precions CDs) onto XFS.
In a few months I started to notice the occasional minor glitch during playback.
Figured it was scheduler or buffer issues, some harmless transient so typical for operating systems then.
It turns out XFS had randomly inserted strings of null bytes into some of my files.
The collection was on three expensive and maxed out 20GB drives so I didn't have a backup.
I didn't feel like ripping everything again so now the glitches permament.

Gird would have warned me that my files were actually being corrupted and I could have
corrected the problem early on and re-ripped just the corrupted albums.

_Doesn't ZFS already have checksumming?_

Yes, if you can use it. But second opinions are welcome.
Gird is a narrow set of suspenders in your belt-and-suspenders setup.

_Isn't this basically what Git does?_

Gird checksums subdirectories and creates a DAG of trust, quite a bit like git.
However, git also duplicates the full contents of the files, which can be a burden.
Gird is meant for environments where the files are gigantic and the backups are offsite.

## Licese

MIT

## Thoughts

This script is intended to protect against driver bugs and cosmic rays.
Cryptographic integrity is _not_ a design goal.

It uses sha1 because, at least on my computers, it's significantly faster than all other algorithms,
including md5 and cksum.

## TODO

* Add --version and --help
* Put the summarize script in contrib

Wishlist:

* Maybe make installation easier/better/more explicit
* Maybe Add --reset to force update all girdfiles
  * Is this really worth adding? `find . -name Girdsums -delete` is pretty darn easy.
* Maybe add a -j option to fork multiple jobs?
  * Maybe just a feedthrough for `xargs -P`. Or maybe take advantage of `parallel` if it's installed.
  * Doesn't seem worth it since a single thread still saturates every SSD I have.
* Consider using Blake https://blake2.net. It's fast!
* `make watch` should store its tmpdir somewhere else so it's possible to still run tests manually
* Maybe make it possible to specify directories with leading hyphens on the command line? `gird -mydir-`
  * Of course `cd -- -mydir- ; gird` works just fine. This is probably not worth fixing.
* Look for sharness alternatives. Does Git's native test runner have the same oddball issues?
  * can't use process substitution in a test block
  * test block errors are very wrong: `sharness.sh: eval: line 383: syntax error`
  * the test-results directory is out of hand. is this sharness's fault?
  * The .t extension appears to be reserved for Perl. Maybe use .sh like Git does, or just .test?
    * played with this a bit but it was rubbing sharness the wrong way. Prob not worth the time.
  * is there an easy way to have each test_expect_success to run in its own subdirectory?
    * right now, an aborted test early in the file causes a cascade of meaningless failures
  * poor documentation on how to write tests
  * seems to run my tests unders zsh even though /bin/sh is bash.
    * `SHELL=/bin/bash bash 02-test.t -v` seems to force bash.
    * Or maybe it's that sometimes it's invoked as /bin/bash (prove) and sometimes as /bin/sh (make)
  * Some tests succeed when run in bash but fail when run in prove.
    * See 02-filenames.t for a heinous workaround.
  * sharness doesn't support --stress?

Non-features:

* Will not attempt error correction. There are other tools for that.
  * Better to just restore the corrupted files from backups.
* Not until rewritten in a real programming language:
  * Won't attempt to print runtime statistics or decent progress info
