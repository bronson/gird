# Gird

When you're storing files for a long time, tiny corruptions can add up.
Gird adds checksums next to each file so those corruptions can be found
soon after they happen instead of years later by accident.

Gird generates hashes for every file in a directory and stores them in
a file named Girdsums. All subdirectories are processed too.
Later, Gird can check these hashes and verify that the contents of
the files are identical to when they were first girded.

## BRAND NEW BRAND NEW BRAND NEW

Don't use this repo yet

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

This creates a .sha1sums file containing the SHA for each file in Photos.
It then operates recursively on all subdirectories, sorted alphabetically.

Running 'gird' without arguments selectes the current directory, identical to typing `gird .`

```bash
gird
```

To verify checksums, run same command:

```bash
gird Photos
```

Gird automatically decides whether it's adding or verifying checksums by the presences of a .sha1sums file in the first directory it processes.

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

I suppose, and DAGs are awesome. But git also copies the full contents of the files.
Gird is meant for environments where files are gigantic and backups are offsite.

## Licese

MIT

## Thoughts

This script is intended to protect against driver bugs and cosmic rays.
Cryptographic integrity is _not_ a design goal.

It uses sha1 because, at least on my computers, it's significantly faster than all other algorithms,
including md5 and cksum.

## TODO

* Replace `processing` with gird's actual action
* Add --continue to keep gird running even if it finds inconsistencies
* Add --reset to force update all girdfiles
* Add filename tests for files and directories starting with hyphens
* Test and document that shasum -c works on girdfiles
* Add --version and --help
* Put the summarize script in contrib

Wishlist:

* Maybe add a -j option to fork multiple jobs?
* Maybe make installation easier/better/more explicit
* Consider using Blake https://blake2.net. It's fast!
* Check on differences between sharness and git (heredoc/process substitution issues).
  * Does Git suffer the same issues or is it just sharness?
  * sharness's error is also very wrong: `sharness.sh: eval: line 383: syntax error`
  * this test-results directory is out of hand. is that sharness's fault?
  * The .t extension appears to be reserved for Perl. Maybe use .sh like Git does, or just .test?
    * played with this a bit but it was rubbing sharness the wrong way. Prob not worth the time.
  * is there an easy way to have each test_expect_success to run in its own subdirectory?
    * right now, an aborted test early in the file causes a cascade of meaningless failures


Non-features:

* Will not attempt error correction. There are other tools for that.
  * Better to just restore the corrupted files from backups.
* Not until rewritten in a real programming language:
  * Won't attempt to print runtime statistics or decent progress info
