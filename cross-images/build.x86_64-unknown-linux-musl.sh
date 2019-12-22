#! /usr/bin/env bash
# Copyright 2019 The Tectonic Project
# Licensed under the MIT License.

[ -n "$IMGUID" ] || IMGUID="$(id -u)"
rust_platform=x86_64-unknown-linux-musl
alpine_platform=x86_64-alpine-linux-musl

cd "$(dirname $0)" && exec docker build \
       -t tectonictypesetting/crossbuild:$rust_platform \
       -f Dockerfile.alpine-chroot \
       --build-arg UID=$IMGUID \
       --build-arg rust_platform=$rust_platform \
       --build-arg alpine_platform=$alpine_platform \
       .
