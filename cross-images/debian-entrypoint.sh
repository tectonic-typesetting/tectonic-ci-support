#! /usr/bin/env bash
# Copyright 2019 the Tectonic Project
# Licensed under the MIT license.

set -euo pipefail

# This script shouldn't be necessary since we don't need to chroot in the
# debian-cross builder, but we want to use the same `cross` driver for that
# and for the alpine-cross one that does, so we have to jump through the same
# hoops.

# Ensure that there exist a user and group with the desired UID/GID.

groupname="$(getent group $HOST_GID |cut -d: -f1 || true)"
if [ -z "$groupname" ] ; then
    groupname="gid${HOST_GID}"
    addgroup -q --gid $HOST_GID "$groupname"
fi

username="$(getent passwd $HOST_UID |cut -d: -f1 || true)"
if [ -z "$username" ] ; then
    username="user${HOST_UID}"
    adduser -q --gid $HOST_GID --uid $HOST_UID --disabled-password --gecos "UID $HOST_UID" "$username"
fi

cur_prim_gid="$(getent passwd $HOST_UID |cut -d: -f4)"
if [ "$cur_prim_gid" -ne "$HOST_GID" ] ; then
    usermod -g $HOST_GID "$username"
fi

# We can now run the command with the desired UID/GID.

export HOME="$(getent passwd $HOST_UID |cut -d: -f6)"
exec sudo -E -u "$username" sh -c '. /environ ; "$@"' -- "${@:-sh}"
