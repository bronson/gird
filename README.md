# Gird

Stores checksums alongside the files that you care about and verifies that they're valid.

```help
usage: gird [--init|--verify|--reset] [--continue|--abort] [directory ...]
```

When you're storing files for a long time, tiny corruptions add up.
`gird --init` adds checksums next to your files, and `gird --verify` ensures the checksums are still correct. IF you periodically verify your girded files, you'll know right when a corruption has happened. And, as a side-effect of reading every byte, the storage media should reallocate any weak sectors that it finds.

## Installation

Gird is a shellscript. Put the `gird` file somewhere on your path.

## Usage

Start by checksumming your files.

### Create Checksums

Start by generating checksums for a directory. In this case the directory is named `Photos` and contains 3 jpegs and 2 subdirectories:

```bash
cd Photos
gird
```

Now every subdirectory will contain a Girdsums file, and every file will have its signature stored in a Girdsums file.

The topmost Girdsums will look something like this:

```txt
b7c51ea62c94d3788305110d60e5ca9ea5664a4e  DSCF1177.JPG
540d71518bf222aaee0380040a3ae85515bfb739  DSCF1178.JPG
eb1625a3241cb805078c8741cfafcdd0829bd825  DSCF1203.JPG
6d8a652eb61f701d56466ba882e4a9d851447325  100_Fuji/Girdsums
afd9f6e638528d7fbd7d2cc8319469fbba8b2737  101_Fuji/Girdsums
```

Those last to lines ensure that subirectories are checksummed too. Even if entire directories disappear, Gird will notice and complain.

### Verify Checksums

Periodically verify your files by running the gird command again:

```bash
$ gird Photos
verifying Photos/100Canon/2019
verifying Photos/100Canon/2020
verifying Photos/100Canon
verifying Photos
gird complete. no errors.
```

If it finds that files have changed, it prints the failing checksums on stderr:

```bash
$ gird Photos
Photos/Phone/OldPics: gird verification failed:
-82913b8c17eee930cce9422b15273d84eda3c0a0  IMG_20140903.jpg
+b52791126f96a21a8ba4d511c6f25a1c1eb6dc9e  IMG_20140903.jpg
gird found 1 problematic directory
```

Now you know which files need to be replaced from backup.

#### Verifying Without Gird

You can also verify a Girdsums files without even using Gird at all:

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
gird assumes `--init` and creates Girdsums files for the
directory and all its subdirectories.

```bash
$ gird --init Photos
initializing Photos/100Canon/2019
initializing Photos/100Canon/2020
initializing Photos/100Canon
initializing Photos
```

When that finishes, every directory will contain a Girdsums file.

Gird does process hidden files and directories, but it skips files named `.DS_Store` (thanks Apple...).

### --verify

If the specified directory already has a Girdsums file in it, then
Gird verifies everything.

```bash
$ gird --verify Photos
verifying Photos/100Canon/2019
verifying Photos/100Canon/2020
verifying Photos/100Canon
verifying Photos
gird complete. no errors.
```

Verify works on read-only media.

### --continue | --abort

By default, gird processes every directory, even if it encounters errors (`--continue`).
If you want to run a quick check and abort at the first error, specify `--abort`:

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

### Remove

To remove all of Gird's files and return the directory to as if Gird had never been run at all, run:

```bash
find Photos -name Girdsums -delete
```

## Testing

The tests use [Sharness](https://github.com/chriscool/sharness). To run them:

```bash
cd t
make
```

## Motivation

I have backups stored in a number of places: local drive, offsite USB drive, and cloud.
If those backups ever disagree, gird knows which file is correct and
which one is corrupt. Before, I'd open the file and scroll around trying to guess which version was the most pristine.

Quick story... In the 1990s I moved my mp3 collection onto XFS. Occasionally there would be a minor glitch during playback, a click or a warble or something.
Figured it was scheduler or buffer issues: some harmless transient that infested operating systems of those days.
Over the next 5 years, with the assitance of PG&E's unreliable power, XFS randomly inserted strings of null bytes into a number of these files.
This collection was on three expensive and maxed out 20GB drives so there was no chance of having a backup.

If I'd had Gird, it would have told me when the first corruption showed up, and I could have just re-ripped that CD.

_But doesn't ZFS already have checksumming?_

Yes! And ZFS is great if it's available [and bug-free](https://github.com/openzfs/zfs/issues/15526). But second opinions are always welcome.
Gird is a narrow set of suspenders in your platform agnostic belt-and-suspenders setup.

_Isn't this basically what Git does?_

Yes, Gird checksums subdirectories and creates a DAG of trust, similar to how Git works.
However, git also duplicates the full contents of the files.
Gird is meant for environments where the files are gigantic and the backups are offsite.

## Thoughts

Gird is intended to protect against driver bugs and cosmic rays.
Cryptographic integrity is not a design goal.

It uses sha1 because, at least on my computers, sha1 is significantly faster than all other
preinstalled algorithms, including md5 and cksum.
One day it may be worth using Blake3 but, right now, even sha1 saturates my SSDs.

Gird is not interested in error correction. There are other tools if you're interested in that rabbit hole.
Gird is meant to be lightweight, allowing you to use it without a second thought, and assumes you'll restore the corrupted files from backups.

## Alternatives

* [fs-verty](https://www.kernel.org/doc/html/latest/filesystems/fsverity.html) (if you're using ext4 on Linux)

## Licese

MIT

## Wishlist

Here are some ideas that didn't make the initial cut.

* The commands should be `gird add *`, `gird rm *`, `gird scan` (metadata only), `gird check/verify` (full file contents)
* Add a --quick flag that checks only metadata and assumes the checksums all match.
* Allow using a single Girdsums file that's not on the filesystem being girded.
  * `gird --file=/tmp/Photos.gird ~/Photos` <-- creates a single deep girdfile
  * How else will you gird a read-only directory (that can't temporarily be made read/write)
  * In some situations I don't want to inject Girdsums into the files being girded.
  * So, by default, Girdsums will be one flat file per directory.
    * But, you can tell Gird to drop all the girdsums in a single file in the root directory.
  * A girded hierarchy can use both styles interchangeably.
  * Therefore, gird should search back up to the root filesystem looking for a deep Girdfile before assuming scattered.
* Bash is now getting really constrictive... it's past time to write in a different language.
  * the inconsistencies in find and sort and dash vs bash vs zsh are just about unsolvable.
* Add a --convert command that quickly converts exploded Girdfiles to single and back.
* Add a --watch command that will watch you reorganize a directory and continually keep Girdfiles up to date.
  * It happily follows all your mvs, renames, deletes, etc.
  * But if it sees any _contents_ of files change, it flips the f out.
* Maybe `gird --add` should be a synonym for `gird --init` and `gird --reset`.
  * "Here, I want you to add this directory to everything being girded"
* Have a way to verify just the hierarchy, not the checksums.
* Have a graft command? Or is --reset adequate? Maybe everything gets subsumed by --add.
  * Not needed. `gird add` and `gird remove` should automatically graft too.
* Talk in the README about grafting and splitting directory trees with Gird.
  * splitting is easy, just do it.
  * grafting requires updating all the Girdsums files from the graft out to the root.
* Questionable directory entries, maybe hard-code to ignore?
  * .git, .svn, .MISC, .Trashes, .TemporaryItems
* Add a `gird --restart` that will verify up until we reach one missing or invalid girdfile, then it will switch to gird --init.
  * That's for when the previous gird --init didn't complete.
  * And maybe it will just verify that directory contents match the Girdfile and not recompute all the checksums?
    * Once it hits a missing or incomplete Girdfile, then it switches over to --init.
  * Is this even necessary when I have gird --reset to restart the process?
    * It's not great... `gird --reset a/b/bad [b-z]*` misses everything else in b. Oh well!
* Better progress info (count # of dirs first, then show countdown while processing)
  * It's easy to count... but I'm not sure how to have find tell the subcommand what index it's on.

* Maybe add a test to ensure similar code snippets in Gird and Contrib are identical.
  * Once we start getting a lot of scripts in contrib.
* Maybe make installation easier/better/more explicit
* Add a .girdignore file that prevents descending into certain subdirectories. (.git. .svn, corruptions, etc)
  * .girdignore would be girded like any other file in the directory. It would just prune subdirectories.
  * However right now we dirwalk using one big find command. Switching to shell recursion would be rough.
  * It can be a good idea to keep your Girdsums files in git. Ignore every file in your .gitignore then add the files you want to track:
    * But now you need to ignore the .git directory!
```bash
$ git init
$ echo '*' > .gitignore
$ find . -name Girdsums -print0 | xargs -0 git add -f
```
  * Nah, doesn't seem worth it. Storing Girdfiles in git doesn't actually buy you much.
* Is there any benefit to removing -n1 from xargs and looping ourselves?
* Remove comments before comparing girdfiles?
  * but how do we ensure reset doesn't kill user's comments?
  * It's probably good that any directory is only represented by one exact girdfile.
  * Add "time to process this directory" as a comment in each girdfile? (worry about reset here)
    * Absolutely not. This will make the files no longer dependent on directory contents.
  * Make Gird support the same file reading conventions as shasum (esp. ignoring # comments)
    * Is this necessary? Maybe girdfiles should be bit-for-bit dependent on directory contents?
* Maybe add a -j option to fork multiple jobs?
  * Doesn't seem worth it since a single thread still saturates my SSDs.
    * Even if I could make Gird infinitely fast, that would only result in a 20% improvement on my system.
  * Might be easy, just be a feedthrough for `xargs -P`.
    * Except, before computing a Girdsums file, need to ensure all subdirs are complete first.
    * Probably not worth the effort until rewritten in a real programming langauge.
* Consider using Blake https://blake2.net. It's fast! And now Blake3 is faster!
* Look for alternatives to sharness. Does Git's native test runner have the same oddball issues?
  * Yes, it has a lot of them. I now think Git's testing infrastructure should remain in git and I should find a better test runner for Bash.
  * Sharness Oddities:
    * can't use process substitution in a test block
    * test block errors are very wrong: `sharness.sh: eval: line 383: syntax error`
    * the test-results directory is out of hand. is this sharness's fault?
    * The .t extension appears to be reserved for Perl. Maybe use .sh like Git does, or just .test?
      * played with this a bit but it was rubbing sharness the wrong way. Prob not worth the time.
    * is there an easy way to have each test\_expect\_success to run in its own subdirectory?
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
