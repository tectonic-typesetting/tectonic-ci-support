#! /bin/bash
# Copyright 2019-2021 The Tectonic Project
# Licensed under the MIT License.

set -xeuo pipefail

export TERM=dumb DEBIAN_FRONTEND=noninteractive

apt-get install -y --no-install-recommends \
        binfmt-support \
        crossbuild-essential-${debian_arch} \
        pkg-config \
        qemu \
        qemu-user-static \
        sudo

# for x86, we have to specify the platform as i386, but the GCC executables are
# named as `i686-linux-gnu...`, which messes things up later. Work around with
# some lame symlinks.

if [ ${debian_platform} = i386-linux-gnu ] ; then
    toolchain_platform=i686-linux-gnu
    pushd /usr/bin

    for t in ${toolchain_platform}-* ; do
        alt=$(echo $t |sed -e s/${toolchain_platform}/${debian_platform}/)
        ln -s $t $alt
    done

    popd
fi

# Must do this in two stages because mips openssl messes up amd64 openssl.

apt-get install -y --no-install-recommends \
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
