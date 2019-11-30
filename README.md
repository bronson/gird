# Gird

Adds checksums to a directory tree so that any corruptions can be discovered
early.

Runing this script generates hashes for every file in a directory tree.
Later, when you can check these hashes, you can verify that the contents of
the files are identical to when you girded them.

## Installation

Copy the `gird` file somewhere on your path.

## Usage

```bash
gird Photos
```

Creates a .sha1sums file containing the SHA for each file in Photos.
It then operates recursively on all subdirectories.

Running 'gird' operates on the current directory, identical to typing 'gird .'

## Motivation

I'm backing up my files to two separate places: local external drive, and cloud.
If those backups ever disagree, gird allows me to see which file is correct and
which one is corrupted.

20 years ago I moved my mp3 collection to XFS. There was an occasional minor glitch
during playback, figured it was scheduler/buffer issues. It turns out XFS had randomly inserted
strings of null bytes into some of my files and, because I had gotten rid of my
non-xfs backup and the original CDs, the glitches are now permament.

Gird would have warned me that my files were being slowly corrupted before erasing
my backups.

_Doesn't ZFS already have checksumming?_

Yes, but second opinions are useful. Gird is a narrow set of suspenders in your belt-and-suspenders setup.

## Thoughts

This script is intended to protect against driver bugs and cosmic
rays. Cryptographic integrity is not a design goal.

It uses sha1 because, on my computers, it's faster than all other algorithms,
including md5 and cksum.
