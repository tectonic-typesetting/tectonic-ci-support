#! /bin/sh
# Copyright 2019 The Tectonic Project
# Licensed under the MIT License.

set -x
set -euo pipefail

uid="$1"

adduser -D -G abuild -u "$uid" rust
sudo -u rust abuild-keygen -an
cp /home/rust/.abuild/*.pub /etc/apk/keys
echo /home/rust/packages/main >>/etc/apk/repositories

rm -f "$0"  # self-destruct
