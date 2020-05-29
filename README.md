# Gird

When you're storing files for a long time, tiny corruptions can add up.
Gird adds checksums next to each file so those corruptions can be found
after they happen, not years later.

Gird generates hashes for every file in a directory tree and stores them in
a .sha1sums file. It then recursively processes all subdirectories.
Later, when you can check these hashes, you can verify that the contents of
the files are identical to when you girded them.

## BRAND NEW BRAND NEW BRAND NEW

Don't use this repo yet

## Installation

Copy the `gird` file somewhere on your path.

## Usage

To generate checksums:

```bash
gird Photos
```

If there's no .sha1sums file in a directory, Gird creates one.

Running 'gird' without arguments selectes the current directory, identical to typing 'gird .'

To verify checksums, run same command:

```bash
gird Photos
```

When there's a .sha1sums file in the first directory gir

Creates a .sha1sums file containing the SHA for each file in Photos.
It then operates recursively on all subdirectories.

## TODO

* How should Gird handle hidden files and directories?  (right now it ignores them)
* Show progress: what directory we're in
  * gird --verbose and gird --silent
* .sha1sums is probably not a good name. Call it Girdfile?
  * If so, we can also stick other data and comments in the file.
* Add explicit arguments for gird --add and gird --verify
  * Also add a --force to tell add and verify to keep processing even if you see inconsistencies
* Add a -j option to fork multiple jobs?
* Consider using Blake https://blake2.net. It's fast!

## Motivation

I'm backing up my files to a number of places: local drive, offsite USB drive, and cloud.
If those backups ever disagree, gird allows me to see which file is correct and
which one is corrupt.

A story... In the 1990s I moved my mp3 collection (painstakingly ripped from precions CDs) onto XFS.
In a few months I started to notice the occasional minor glitch
during playback. Figured it was scheduler or buffer issues, some harmless transient so typical for the time.
It turns out XFS had randomly inserted strings of null bytes into some of my files and, because I had gotten rid of my
non-xfs backup (I had 3 20GB drives and was maxed out) and I didn't feel like going through the whole ripping process
again, the glitches are now permament.

Gird would have warned me that my files were being slowly corrupted and maybe I could have caught the issue
before it was widespread.

_Doesn't ZFS already have checksumming?_

Yes, if you can use it. But second opinions are always useful. Gird is a narrow set of suspenders in your belt-and-suspenders setup.

_Isn't this basically what Git does?_

Yes, and DAGs are awesome. Git, however, also copies the full contents of all the files. Gird is meant for environments where
files are gigantic and backups are offsite.

## Licese

MIT

## Thoughts

This script is intended to protect against driver bugs and cosmic
rays. Cryptographic integrity is _not_ a design goal.

It uses sha1 because, at least on my computers, it's significantly faster than all other algorithms,
including md5 and cksum.
