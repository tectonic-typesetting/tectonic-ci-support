#! /bin/sh
# Copyright 2019 The Tectonic Project
# Licensed under the MIT License.

set -x
set -euo pipefail

alpine_arch="$1"
/mini-aports/scripts/bootstrap.sh "$alpine_arch"

rm -f "$0"
