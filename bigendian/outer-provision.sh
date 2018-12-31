#! /bin/bash
# Copyright 2018 the Tectonic Project
# Licensed under the MIT License.
#
# Provision the Ubuntu VM that we will use to make a PowerPC install that is
# ready to build Tectonic inside a different Ubuntu VM later. Phew!

set -e -x

mirror=http://ports.ubuntu.com/
version=xenial # last one to have ppc
arch=powerpc
qemu_arch=ppc
rust_version=1.31.1
root=/buildenv-$arch

# The basic Vagrant bionic box has a really small (2 GB) disk, and we fill it
# up pretty easily. It helps to remove some of the packages that come
# preinstalled in the Vagrant box.

sudo apt-get update
sudo apt-get remove -y \
     'linux-headers*' \
     snapd
sudo apt-get install -y \
     binfmt-support \
     curl \
     debootstrap \
     qemu-user-static
sudo apt autoremove -y

# For some reason, rustup doesn't work for PPC. We can just download and run
# the installer manually. We unpack it into /vagrant to work around the
# aforementioned disk space issues.

cd /vagrant
curl -fsS https://static.rust-lang.org/dist/rust-$rust_version-powerpc-unknown-linux-gnu.tar.gz |tar xz

# Prep the PPC chroot.

sudo debootstrap --foreign --no-check-gpg --arch=$arch $version $root $mirror
sudo cp /usr/bin/qemu-${qemu_arch}-static $root/usr/bin/
sudo mkdir $root/vagrant
sudo mount --bind /vagrant $root/vagrant
sudo mount -t proc /proc $root/proc
sudo chroot $root ./debootstrap/debootstrap --second-stage
sudo apt-get remove -y debootstrap
sudo mount -t proc /proc $root/proc # this seems to get unmounted or something?

# The remainder of the setup happens inside the chroot.

exec sudo -i chroot $root bash /vagrant/inner-provision.sh
