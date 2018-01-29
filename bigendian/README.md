# Tectonic Big-Endian CI

The original WEB2C implementation of TeX includes some infrastructure to
produce format files that are portable to CPU architectures that are either
big-endian (like old PowerPC) or little-endian (like Intel). We would like to
test this portability in Tectonic's CI, both regarding the specific
correctness of the code with regards to endianness, and more generally to make
sure that we're not making undue assumptions about the underlying CPU
platform.

As far as I ([PKGW](https://github.com/pkgw/)) can tell, there are no free
public CI services that let you build on a big-endian platform. But, with some
persistence and some truly gross hacks, you can indeed test your big-endian
code.

The key is to use [QEMU](https://www.qemu.org/) to simulate a big-endian CPU
on your x86 CI platform. With the right OS setup and a chroot, you can run the
whole build process inside such an environment.

The scripts in this directory create a tarball of files that can be deployed
in such a chroot to test the Tectonic build. It comes preloaded with the
necessary compilers and dependencies, making CI testing straightforward.

We use Ubuntu as the base OS because the is the first one for which I found
[instructions on making a QEMU build chroot](https://www.tomaz.me/2013/12/02/running-travis-ci-tests-on-arm.html).

The most promising CPU that has a big-endian
[Ubuntu port](http://ports.ubuntu.com/) is PowerPC, so that's our target CPU.
However, the last version of Ubuntu to provide a PowerPC port is
[16.04 Xenial Xerus](http://releases.ubuntu.com/16.04/), so we have to use
that version. Fortunately, as seen elsewhere in this repo, I’ve already
backported a sufficiently new
[harfbuzz](https://www.freedesktop.org/wiki/Software/HarfBuzz/) to that OS.

For speed during the actual CI, we pre-install the Rust compilers. The
version used is specified in the `outer-provision.sh` script.

This directory contains tools to actually generate the chroot tarball that
sets up the build environment in the CI process. It does that using an Ubuntu
VM running inside [Vagrant](https://www.vagrantup.com/). When the VM is provisioned,
the chroot environment is set up and the needed tools are installed.

The script `./make-chroot.sh` creates the Vagrant box and generates the chroot
tarball, which is saved as `buildenv-powerpc.tar.gz`.
