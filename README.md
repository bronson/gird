# Gird

Stores checksums alongside files that you care about and verifies
that they're valid.

```help
usage: gird [--init|--verify|--reset] [--continue|--abort] [directory ...]
```

When you're storing files for a long time, tiny corruptions can add up.
`gird --init` adds checksums next to your files so corruptions can be found and corrected.

Later, when you periodically `gird --verify` your files, every checksum is verified.
If you find a failure, you know the corruption happened only since the last time you
ran gird. And, as a side-effect of reading every byte, the drive will hopefully
reallocate any weak sectors that it finds.

## Installation

Gird is a shellscript. Put the `gird` file somewhere on your path.

## Introduction

Let's generate checksums for a directory named `Photos` which contains 3 jpegs and 2 subdirectories:

```bash
gird Photos
```

This will produce Girdsums files in this directory and all subdirectories.
The topmost Girdsums file will look something like this:

```txt
b7c51ea62c94d3788305110d60e5ca9ea5664a4e  DSCF1177.JPG
540d71518bf222aaee0380040a3ae85515bfb739  DSCF1178.JPG
eb1625a3241cb805078c8741cfafcdd0829bd825  DSCF1203.JPG
6d8a652eb61f701d56466ba882e4a9d851447325  100_Fuji/Girdsums
afd9f6e638528d7fbd7d2cc8319469fbba8b2737  101_Fuji/Girdsums
```

The bottom two lines checksum the Girdsums files in subdirectories
even if entire directories disappear, Gird will still notice and complain.

Now, periodically verify your files by running the gird command again:

```bash
$ gird Photos
verifying Photos/100Canon/2019
verifying Photos/100Canon/2020
verifying Photos/100Canon
verifying Photos
gird complete. no errors.
```

If it finds that files have changed, it prints the checksums on stderr:

```txt
Photos/Phone/OldPics: gird verification failed:
-82913b8c17eee930cce9422b15273d84eda3c0a0  IMG_20140903.jpg
+b52791126f96a21a8ba4d511c6f25a1c1eb6dc9e  IMG_20140903.jpg
gird found 1 problematic directory
```

And now you know what files need to be replaced from backup.

You can also verify your Girdsums files without using Gird at all:

```bash
shasum -c Girdsums
```

## Arguments

Gird accepts any number of directories on the command line:

```bash
gird --verify archive1 archive2 photos videos
```

Like many shell commands, gird accepts the `--` argument to specify that all further arguments are directories that should be processed:

```bash
gird -- -dir1- -dir2-
```

Running 'gird' without arguments starts in the current directory, identical to typing `gird .`:

```bash
gird
```

### --init

If the specified directory doesn't already have a Girdsums file, then
Gird goes into initialize mode and creates Girdsums files for the
directory and all its subdirectories.

You can also be explicit:

```bash
$ gird --init Photos
initializing Photos/100Canon/2019
initializing Photos/100Canon/2020
initializing Photos/100Canon
initializing Photos
```

Gird does process hidden files and directories, but it skips files named `.DS_Store` (thanks Apple...).

### --verify

If the specified directory already has a Girdsums file in it, then
Gird verifies the whole hierarchy.

You can also be explicit:

```bash
$ gird --verify Photos
verifying Photos/100Canon/2019
verifying Photos/100Canon/2020
verifying Photos/100Canon
verifying Photos
gird complete. no errors.
```

Verify works great on read-only media.

### --continue|--abort

By default, gird processes every directory, even if it encounters errors (`--continue`).
If you want to abort at the first error, specify `--abort`:

```bash
gird --abort --verify Photos
```

### --reset

Asks gird to update its checksums for a directory.

Let's say that you updated `Photos/Fuji/DSCF0013.JPG` and now `gird --verify` is complaining.
 ask Gird to reset just that directory:

```bash
gird --reset Photos/Fuji
```

Or this will do the same thing:

```bash
cd Photos/Fuji
gird --reset
```

## Testing

The tests use [Sharness](https://github.com/chriscool/sharness). To run them:

```bash
cd t
make
```

## Motivation

I have backups stored in a number of places: local drive, offsite USB drive, and cloud.
If those backups ever disagree, gird allows me to see which file is correct and
which one is corrupt. Before, I'd have to open the file and try to guess which version
was correct.

Quick story... In the 1990s I moved my mp3 collection (painstakingly ripped from precions CDs) onto XFS.
In a few months I started to notice the occasional minor glitch during playback.
I figured it was scheduler or buffer issues: some harmless transient so typical of operating systems back then.
Over the next 5 years, with the assitance of power outages, XFS randomly inserted strings of null bytes into a few of my files.
This collection was on three expensive and maxed out 20GB drives so there was no chance of having a backup.
I didn't discover the corruption until I'd given all my CDs away (and, even if I had, I wasn't about to rip everything again).

If I'd had Gird, it would have told me when the first corruption showed up, and I could
have immediately investigated the issue and replaced only that file.

_But doesn't ZFS already have checksumming?_

Yes! And it's great if you can use it. But second opinions are always welcome.
Gird is a narrow set of suspenders in your multiplatform belt-and-suspenders setup.

_Isn't this basically what Git does?_

Gird checksums subdirectories and creates a DAG of trust, similar to Git.
However, git also duplicates the full contents of the files, which is a huge burden.
Gird is meant for environments where the files are gigantic and the backups are offsite.

## Thoughts

Gird is intended to protect against driver bugs and cosmic rays.
Cryptographic integrity is _not_ a design goal.

It uses sha1 because, at least on my computers, sha1 is significantly faster than all other
preinstalled algorithms, including md5 and cksum.

Gird is not interested in error correction. There are other tools for that.
Gird is meant to be lightweight, allowing you to restore the corrupted files from backups
the same week they get corrupted.

## Licese

MIT

## Very Wishlist

Here are some ideas that didn't make the initial cut.

* Maybe make installation easier/better/more explicit
* Is there any benefit to removing -n1 from xargs and looping ourselves?
* Maybe add a -j option to fork multiple jobs?
  * Doesn't seem worth it since a single thread still saturates every SSD I have.
  * Might be easy, just be a feedthrough for `xargs -P`.
    * Except, before computing a Girdsums file, need to ensure all subdirs are complete first.
    * Probably not worth the effort until rewritten in a real programming langauge.
* Consider using Blake https://blake2.net. It's fast! And now Blake3 is faster!
* Look for alternatives to sharness. Does Git's native test runner have the same oddball issues?
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
  * `make watch` should store its tmpdir somewhere else so it's possible to still run tests manually
  * Why does `prove *.t` show "Dubious, test returned 1 (wstat 256, 0x100)" instead of "fail"?
