#! /usr/bin/env bash

set -x
set -euo pipefail

TARGET_ARCH="$1"

if [ $TARGET_ARCH == native ] ; then
    root=/
else
    root=/home/rust/sysroot-$TARGET_ARCH

    # Packages for other architectures are signed with other keys that we need to load up.
    cd /etc/apk/keys
    for fp in 4d07755e 524d27bb 58199dcc 58cbb476 58e4f17d ; do
        wget https://alpinelinux.org/keys/alpine-devel@lists.alpinelinux.org-$fp.rsa.pub
    done

    # Propagate the new keys into the sysroot and also tell it to start pulling in
    # packages from the internet.
    cp /etc/apk/keys/* $root/etc/apk/keys/
    cp /etc/apk/repositories $root/etc/apk/
fi

# g++ is needed to get libstdc++.a, annoyingly
apk --root $root add --no-scripts \
    bzip2-dev \
    expat-dev \
    fontconfig-dev \
    freetype-dev \
    freetype-static \
    g++ \
    graphite2-dev \
    graphite2-static \
    harfbuzz-dev \
    harfbuzz-icu \
    harfbuzz-static \
    icu-dev \
    icu-static \
    libpng-dev \
    libpng-static \
    openssl-dev \
    zlib-dev

if [ $TARGET_ARCH != native ] ; then
    # Let's also install those cross-compilers!
    apk add build-base-$TARGET_ARCH gcc-$TARGET_ARCH g++-$TARGET_ARCH
fi

rm -f "$0"  # self-destruct
