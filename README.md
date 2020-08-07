# Gird

Stores checksums alongside files that you care about and verifies
that they're valid.

```txt
usage: gird [--init|--verify|--reset] [--continue|--abort] [directory ...]
```

When you're storing files for a long time, tiny corruptions can add up.
Gird adds checksums next to each file so those corruptions can be found
soon after they happen instead of years later by accident. If you periodically
`gird --verify` your files, this ensures your checksums still match.
And, as a side-effect of reading every byte, the drive might rewrite/reallocate
any weak sectors it notices.

The checksums are stored in each directory in a file named `Girdsums`.
The format of this file is identical to the output of the
[shasum](https://metacpan.org/release/Digest-SHA/source/shasum) command.

## Installation

Gird is a shellscript. Put the `gird` file somewhere on your path.

## Usage

### Initialize

To generate checksums for a directory named `Photos`:

```bash
gird Photos
```

This creates a Girdsums file containing the SHA for each file in Photos.
It also operates recursively on all subdirectories in the given directory.

Gird knew that you wanted to initialize the directory because it didn't
alreay contain a `Girdsums` file. You can also force Gird into this mode
so it doesn't need to guess:


```bash
$ gird --init Photos
initializing Photos/100Canon/2019
initializing Photos/100Canon/2020
initializing Photos/100Canon
initializing Photos
```

Running 'gird' without arguments starts in the current directory, identical to typing `gird .`:

```bash
gird
```

Gird does process hidden files and directories. It skips files named `.DS_Store`.

### Verify

To verify your files, just run the `gird` command again.
Since there's now a Girdsums file in that directory, Gird knows it should
verify the Girdsums files rather than creating them.

```bash
$ gird Photos
verifying Photos/100Canon/2019
verifying Photos/100Canon/2020
verifying Photos/100Canon
verifying Photos
gird complete. no errors.
```

Or you can be explicit so Gird will abort if it doesn't find existing checksums:

```bash
gird --verify Photos
...
```

### Continue vs. Abort

Gird normally processes everything, even if it encounters errors (`--continue`).
If you are doing a quick check and want to abort at the first error, specify `--abort`:

```bash
gird --abort --verify Photos
```

### Reset

If a directory's contents have changed, and you like this, you can reset
just the changed directory.
This ensures your archive remains consistent without having to recompute
every file.

Let's say that a file in `Photos/Canon/SX10/April` has been updated, and
`gird --verify` is now complaining.
To update the Girdsums files, run this:

```bash
gird --reset Photos/Canon/SX10/April
```

Or this will do the same thing:

```bash
cd Photos/Canon/SX10/April
gird --reset
```

### Trivia


## Girdsums File

Girdsums stores the SHA checksums of each file in the current directory (including hidden files, but ignoring `.DS_Store`) in the `shasum` command's native format.

In addition to using `gird --verify`, you can check Girdsums files by passing them to shasum:

```bash
shasum -c Girdsums
```

## Testing

The tests use [Sharness](https://github.com/chriscool/sharness). To run them:

```bash
cd t
make
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

## Thoughts

This script is intended to protect against driver bugs and cosmic rays.
Cryptographic integrity is _not_ a design goal.

It uses sha1 because, at least on my computers, it's significantly faster than all other algorithms,
including md5 and cksum.

Zero interest in error correction. There are other tools for that.
Gird is for detection so you can restore the corrupted files from backups.

There are a number of limitations that are gated on being written in a better programming language (such as a proper progress display, keeping track of runtime metrics, less important things like that). However, because Gird is currently faster than any SSDs I have, there's very little incentive to do this.

## Licese

MIT

## Very Wishlist

Here are some ideas that didn't make the initial cut.

* Maybe make installation easier/better/more explicit
* Is there any performance benefit to removing -n1 from xargs and looping ourselves?
* Maybe add a -j option to fork multiple jobs?
  * Doesn't seem worth it since a single thread still saturates every SSD I have.
  * Might be easy, just be a feedthrough for `xargs -P`.
    * Except, before computing a Girdsums file, need to ensure all subdirs are complete first.
    * Probably not worth the effort until rewritten in a real programming langauge.
* If you're initializing, you probably want --abort. If verifying, you probably want --continue.
  * Because, if there's an error while initializing, continuing will probably thrash uselessly.
  * Is it worth being smart about deciding to continue? Probably not.
* Consider using Blake https://blake2.net. It's fast!
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
  * `make watch` should store its tmpdir somewhere else so it's possible to still run tests manually
  * Why does `prove *.t` show "Dubious, test returned 1 (wstat 256, 0x100)" instead of "fail"?
