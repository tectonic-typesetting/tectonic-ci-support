#! /bin/sh
# Copyright 2019 The Tectonic Project
# Licensed under the MIT License.

set -x
set -eu  # no `-o pipefail` in sh

cd /

export TERM=dumb
apt-get update
apt-get install -y pkg-config sudo
apt-get clean
rm -rf /var/lib/apt/lists/*

# XXXX parametrize UID correctly
useradd rust --user-group --home-dir /alpine/home/rust --shell /bin/bash --groups sudo --uid 1000

chmod +x /alpine/enter-chroot

echo 'rust ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/rust-nopasswd

rm -f "$0"  # self-destruct
