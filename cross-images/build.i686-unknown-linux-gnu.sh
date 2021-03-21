#! /usr/bin/env bash
# Copyright 2019-2021 The Tectonic Project
# Licensed under the MIT License.

[ -n "$IMGUID" ] || IMGUID="$(id -u)"
rust_platform=i686-unknown-linux-gnu
debian_platform=i386-linux-gnu
debian_arch=i386
qemu_arch=native

cd "$(dirname $0)" && \
    exec docker build \
         -t tectonictypesetting/crossbuild:$rust_platform \
         -f Dockerfile.debian-cross \
         --build-arg UID=$IMGUID \
         --build-arg rust_platform=$rust_platform \
         --build-arg debian_platform=$debian_platform \
         --build-arg debian_arch=$debian_arch \
         --build-arg qemu_arch=$qemu_arch \
         .
