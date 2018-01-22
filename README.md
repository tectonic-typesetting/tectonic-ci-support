# Tectonic Continuous Integration (CI) Support

Tectonic uses [Travis CI](https://travis-ci.org/) for continuous integration.
It has turned out that some pieces of useful CI functionality (e.g. code
coverage analysis) need extra software support. This repository contains
support infrastructure for providing this support.

At the moment, this repo mostly contains notes and fragments. Hopefully we'll
tidy it up over time.


## The tectonic-ci Ubuntu package archive

Prepackaged software can be installed into Tectonic CI Linux machines through
a dedicated Ubuntu
[Personal Package Archive](https://launchpad.net/ubuntu/+ppas) known as
[k-peter/tectonic-ci](https://launchpad.net/~k-peter/+archive/ubuntu/tectonic-ci).
This is under the personal control of [@pkgw](https://github.com/pkgw).
Hopefully this will not turn out to be a limiting factor.


## Updated libharfbuzz

The PPA provides an updated verison of
[harfbuzz](https://www.freedesktop.org/wiki/Software/HarfBuzz/). The latest
version of Ubuntu currently supported by Travis is
[xenial](http://releases.ubuntu.com/16.04/), and this only provides version
1.0.1 of harfbuzz. But Tectonic requires at least version 1.3.3.

The PPA harfbuzz package is a backport made
[following these directions](https://opensourcehacker.com/2013/03/20/how-to-backport-packages-on-ubuntu-linux/).
The approximate recipe for backporting other packages is something like:

1. Run an interactive Docker container using the `ubuntu:xenial` image.
2. `apt-get update`
3. `apt-get install ubuntu-dev-tools` (and maybe `emacs24-nox` for development)
4. Get the PPA GPG key into the Docker container (`docker cp`; `chown`)
5. `echo DEBSIGN_KEYID=1E73EE55 >~/.devscripts`
6. `export DEBFULLNAME="Peter Williams" DEBEMAIL=peter@newton.cx UBUMAIL=peter@newton.cx`
7. `backportpackage -u ppa:k-peter/tectonic-ci $packagename`

If everything goes well the servers of launchpad.net will then build binary
versions of the package.

**TODO**: canned script for setting up a reasonable Docker container;
obviously we have to have some secure mechanism for dealing with the GPG key,
though.


## Newer kcov

We also provide a newer version of
[kcov](https://simonkagstrom.github.io/kcov/) that is compatible with
[cargo-kcov](https://github.com/kennytm/cargo-kcov). The version we want is
newer than any one packaged in Ubuntu/Debian, as far as I can tell, so I tried
my hand at making a new Debian package by hand. The support files for that are
[in this repo](kcov/).

Very handwavey recipe for building and uploading a package:

1. Download release tarball; I think you need to save it named as something like
   `kcov_34+tectonicci1.orig.tar.gz` in the root directory of this package.
2. Create and setup a Docker container as in the harfbuzz recipe; have it
   mount this repo read-write somewhere.
3. Run `debbuild -S` in the `kcov/` subdirectory.
4. In this toplevel directory, run `dput ppa:k-peter/tectonic-ci
   kcov_34+tectonicci1_source.changes` if/when the updated source package is
   created.

I had a lot of trouble trying to get the `quilt` patching framework to do what
I wanted, but I think some judicious use of Git and manual patch creation will
probably keep things covered.

Note that Debian repackages the original `kcov` source due to
[DFSG](https://en.wikipedia.org/wiki/Debian_Free_Software_Guidelines) matters,
but we can afford to be laxer.
