#! /usr/bin/env bash
# Copyright 2019 the Tectonic Project
# Licensed under the MIT license.

set -euo pipefail

# Unlike the standard `cross` setup, this container will be entered as user
# root, but the environment variables $HOST_UID and $HOST_GID will be set. We
# need this to set up the bind mounts that will be used by our chroot:

if [ ! -f /did-setup ] ; then
    for dir in proc sys dev project target cargo xargo rust ; do
        mkdir -p /alpine/$dir
        mount --bind /$dir /alpine/$dir
        mount --make-private /alpine/$dir
    done

    touch /did-setup
fi

# Now, ensure that there exist a user and group with the desired UID/GID,
# since the container may have been built with settings different than
# expected on the host system. We also have to do this inside the alpine
# chroot since we need to "su" back to the user within the chroot execution.

groupname="$(getent group $HOST_GID |cut -d: -f1 || true)"
if [ -z "$groupname" ] ; then
    groupname="gid${HOST_GID}"
    addgroup -q --gid $HOST_GID "$groupname"
    /alpine/enter-chroot addgroup -g $HOST_GID "$groupname"
fi

username="$(getent passwd $HOST_UID |cut -d: -f1 || true)"
if [ -z "$username" ] ; then
    username="user${HOST_UID}"
    adduser -q --gid $HOST_GID --uid $HOST_UID --disabled-password --gecos "UID $HOST_UID" "$username"
    /alpine/enter-chroot adduser -D -G "$groupname" -u $HOST_UID "$username"
fi

cur_prim_gid="$(getent passwd $HOST_UID |cut -d: -f4)"
if [ "$cur_prim_gid" -ne "$HOST_GID" ] ; then
    usermod -g $HOST_GID "$username"
    /alpine/enter-chroot deluser "$username"
    /alpine/enter-chroot adduser -D -G "$groupname" -u $HOST_UID "$username"
fi

# We can now run the command with the desired UID/GID.

export HOME="$(getent passwd $HOST_UID |cut -d: -f6)"
exec sudo -E -u "$username" sh -c '. /environ ; "$@"' -- "${@:-sh}"
