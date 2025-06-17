# Tectonic Continuous Integration (CI) Support

Tectonic uses [Azure Pipelines][ap] for continuous integration. It has turned
out that some pieces of useful CI functionality need extra software support.
This repository contains infrastructure for providing this support.

[ap]: https://azure.microsoft.com/en-us/services/devops/pipelines/

## Custom `cross` images

We need to create custom images used by [`cross`] to
build Tectonic. Scripts to create them are in the `cross-images/` directory.

See the `README.md` in the `cross-images` subdirectory for more information.
That file documents the workflow for attempting your own cross-compilation of
Tectonic.


## Old stuff

Check the Git history for:

- Updated `kcov` package for old Ubuntus
- Updated `libharfbuzz` package for old Ubuntus
- Old CI helper tool `ttcitool`, superseded by [Cranko]
- Custom PPC build chroot for testing Tectonic on bigendian systems
- Custom cross build for custom docker behavior on old cross versions

[Cranko]: https://pkgw.github.io/cranko/
