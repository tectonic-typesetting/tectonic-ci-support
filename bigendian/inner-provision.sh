#! /bin/bash
# Copyright 2018 the Tectonic Project
# Licensed under the MIT License.
#
# This script is run inside a Ubuntu Xenial chroot that has been configured to
# pretend it is running on a PowerPC processor via qemu. It is run as root and
# /vagrant is bind-mounted inside the chroot.

set -e -x

rust_platform=powerpc-unknown-linux-gnu

# Configure the PPA that will get us the appropriately new harfbuzz.

echo 'deb http://ppa.launchpad.net/k-peter/tectonic-ci/ubuntu xenial main' >/etc/apt/sources.list.d/ppa.list
gpg --ignore-time-conflict --no-options --no-default-keyring \
    --secret-keyring /etc/apt/secring.gpg --trustdb-name /etc/apt/trustdb.gpg \
    --keyring /etc/apt/trusted.gpg --primary-keyring /etc/apt/trusted.gpg \
    --keyserver keyserver.ubuntu.com --recv-keys 95BF9DFC21BD99D29A57F488F24509F1CBDF05DD

# Packages

apt-get update
apt-get --allow-unauthenticated install -y \
        curl \
        g++ \
        libgraphite2-dev \
        libharfbuzz-dev \
        libfontconfig1-dev \
        libicu-dev \
        libssl-dev \
        openssl \
        zlib1g-dev

# Install rust tools

cd /vagrant/rust-*-$rust_platform
./install.sh --components=rustc,cargo,rust-std-$rust_platform
