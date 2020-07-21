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

## Testing

Using [Sharness](https://github.com/chriscool/sharness).

To run tests:

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

I suppose. DAGs are awesome. Git also copies the full contents of all the files. Gird is meant for environments where
files are gigantic and backups are offsite.

## Licese

MIT

## Thoughts

This script is intended to protect against driver bugs and cosmic
rays. Cryptographic integrity is _not_ a design goal.

It uses sha1 because, at least on my computers, it's significantly faster than all other algorithms,
including md5 and cksum.

## TODO

* How should Gird handle hidden files and directories?  (right now it ignores them)
* Show progress: what directory we're in
  * gird --verbose and gird --silent
* Add explicit arguments for gird --add and gird --verify
  * Also add a --force to tell add and verify to keep processing even if you see inconsistencies
* Add a -j option to fork multiple jobs?
* Consider using Blake https://blake2.net. It's fast!
* Check on differences between sharness and git (heredoc/process substitution issues).
  * Does Git suffer the same issues or is it just sharness?
* make installation easier/better/more explicit
