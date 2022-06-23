# Tectonic Continuous Integration (CI) Support

Tectonic uses [Azure Pipelines][ap] for continuous integration. It has turned
out that some pieces of useful CI functionality need extra software support.
This repository contains infrastructure for providing this support.

[ap]: https://azure.microsoft.com/en-us/services/devops/pipelines/


## Custom `cross` program

In order to do all sorts of tricky cross-compilation tests, we need to use a
customized version of the [`cross`] program. The `custom-cross/` directory
contains the files needed to create it. We do a creative/ingenious/weird/dumb
thing where we distribute the customized binary as a Docker container that just
copies the binary out of the container to the host.

[`cross`]: https://github.com/cross-rs/cross


## Custom `cross` images

As a less weird thing, we need to create custom images used by [`cross`] to
build Tectonic. Scripts to create them are in the `cross-images/` directory.


## Old stuff

Check the Git history for:

- Updated `kcov` package for old Ubuntus
- Updated `libharfbuzz` package for old Ubuntus
- Old CI helper tool `ttcitool`, superseded by [Cranko]
- Custom PPC build chroot for testing Tectonic on bigendian systems

[Cranko]: https://pkgw.github.io/cranko/
