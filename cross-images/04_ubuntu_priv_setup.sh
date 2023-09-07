#! /bin/sh
# Copyright 2019 The Tectonic Project
# Licensed under the MIT License.

set -x
set -eu  # no `-o pipefail` in sh

UID="$UID"

cd /

export TERM=dumb DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends build-essential pkg-config sudo
apt-get clean
rm -rf /var/lib/apt/lists/*

useradd rust --user-group --home-dir /alpine/home/rust --shell /bin/bash --groups sudo --uid $UID

chmod +x /alpine/enter-chroot

# The container might be executed as a different UID than we've assigned to
# `rust`, so we have to be prepared to anyone to sudo.
echo 'ALL ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/partytime

rm -f "$0"  # self-destruct
