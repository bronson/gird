# Gird

Run this script to generate hashes for every file in a directory tree.
Later, you can check these hashes, and verify that the files haven't been
corrupted.

# Installation

Copy the `gird` file somewhere on your path.

# Usage

```
$ gird Photos
```

Creates a .sha1sums file containing the SHA for each file in Photos.
It then operates recursively on all subdirectories.

Running 'gird' operates on the current directory, identical to typing 'gird .'

# Testing

Run `./gird test` in the home directory.
If git shows no differences, then gird worked.

# Motivation

I still have some MP3s that were damaged when xfs inserted long strings of 0s.
If I had girded my MP3s, I would have noticed before erasing my backups.

_Doesn't ZFS already have checksumming?_

Yes. Gird is the narrow set of suspenders in your belt-and-suspenders setup.

# Thoughts

This script is intended to protect against driver bugs and cosmic
rays. Cryptographic integrity is not a design goal.

It's currently hard-coded to use sha1 because that's faster than all other
algorithms, including md5 and cksum (on my Mac anyway).