#! /usr/bin/env bash
# Copyright 2023 The Tectonic Project
# Licensed under the MIT License.

[ -n "$IMGUID" ] || IMGUID="$(id -u)"
rust_platform=aarch64-unknown-linux-musl
alpine_platform=aarch64-alpine-linux-musl
alpine_arch=aarch64
qemu_arch=aarch64

cd "$(dirname $0)" && exec docker build \
       -t tectonictypesetting/crossbuild:$rust_platform \
       -f Dockerfile.alpine-chroot-cross \
       --build-arg UID=$IMGUID \
       --build-arg rust_platform=$rust_platform \
       --build-arg alpine_platform=$alpine_platform \
       --build-arg alpine_arch=$alpine_arch \
       --build-arg qemu_arch=$qemu_arch \
       .
