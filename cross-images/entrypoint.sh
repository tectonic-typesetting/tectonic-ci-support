#! /usr/bin/env bash
# Copyright 2019 the Tectonic Project
# Licensed under the MIT license.

set -euo pipefail

if [ ! -f /did-setup ] ; then
    for dir in proc sys dev project target cargo xargo rust ; do
        sudo mkdir -p /alpine/$dir
        sudo mount --bind /$dir /alpine/$dir
        sudo mount --make-private /alpine/$dir
    done

    sudo touch /did-setup
fi

. /environ
exec "$@"
