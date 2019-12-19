#! /usr/bin/env bash
# Copyright 2019 The Tectonic Project
# Licensed under the MIT License.

[ -n "$UID" ] || UID="$(id -u)"
rust_platform=arm-unknown-linux-musleabihf
alpine_platform=armv6-alpine-linux-musleabihf
alpine_arch=armhf
qemu_arch=arm

docker build \
       -t tectonictypesetting/crossbuild:$rust_platform \
       -f Dockerfile.alpine-chroot-cross \
       --build-arg UID=$UID \
       --build-arg rust_platform=$rust_platform \
       --build-arg alpine_platform=$alpine_platform \
       --build-arg alpine_arch=$alpine_arch \
       --build-arg qemu_arch=$qemu_arch \
       .
