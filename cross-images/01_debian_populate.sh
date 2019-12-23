#! /bin/bash
# Copyright 2019 The Tectonic Project
# Licensed under the MIT License.

set -xeuo pipefail

apt-get install -y \
        binfmt-support \
        crossbuild-essential-${debian_arch} \
        pkg-config \
        qemu \
        qemu-user-static \
        sudo

# Must do this in two stages because mips openssl messes up amd64 openssl.

apt-get install -y \
        libgraphite2-dev:${debian_arch} \
        libharfbuzz-dev:${debian_arch} \
        libfontconfig1-dev:${debian_arch} \
        libfreetype6-dev:${debian_arch} \
        libicu-dev:${debian_arch} \
        libssl-dev:${debian_arch} \
        openssl:${debian_arch} \
        zlib1g-dev:${debian_arch}

apt-get clean
rm -rf /var/lib/apt/lists/*

rm -f "$0"  # self-destruct
