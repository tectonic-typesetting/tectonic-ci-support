#! /usr/bin/env bash
# Copyright 2019 The Tectonic Project
# Licensed under the MIT License.

# NOTE: As of summer 2023, Rust has dropped MIPS to Tier 3 support, so it has
# been removed from Tectonic's CI system. This file is preserved for posterity
# but is unlikely to remain functional for long.

[ -n "$IMGUID" ] || IMGUID="$(id -u)"
rust_platform=mips-unknown-linux-gnu
debian_platform=mips-linux-gnu
debian_arch=mips
qemu_arch=mips

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
