# [Gird](https://github.com/bronson/gird) Changelog

## [1.0.0] - 2020-08-07

* print a summary after verifying to ensure errors won't be missed
* handle specifying directories with a leading dash (`gird -- -dir-`)
* make --continue the default instead of aborting at the first error
* add --reset to reset the Girdfiles in specific directories

## [0.9] - 2020-07-29

* rename --create to --init since it should be more familiar
* also gird the Girdsums files in subdirectories to create a tree of trust
* Store the sums in `Girdfile` instead of `.sha1sums` file
* ignore .DS_Store files
* process hidden files and directories too (with leading dot: .hidden)

[1.0.0]: https://github.com/bronson/gird/compare/v0.9...v1.0.0
[0.9]: https://github.com/bronson/gird/releases/tag/v0.9
