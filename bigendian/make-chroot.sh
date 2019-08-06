#! /bin/bash
# Copyright 2018-2019 the Tectonic Project
# Licensed under the MIT License.
#
# All-in-one script to make the chroot tarball.

set -e -x
vagrant up
vagrant ssh -c "sudo tar czf /vagrant/tectonic-buildenv-ppc.tar.gz -C /buildenv-powerpc bin dev etc lib root run sbin usr var"
