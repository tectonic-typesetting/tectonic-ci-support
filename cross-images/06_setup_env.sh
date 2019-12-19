#! /bin/sh
# Copyright 2019 The Tectonic Project
# Licensed under the MIT License.

set -x
set -eu  # no `-o pipefail` here

rust_platform="$1"
os_platform="$2"
os_arch="$3"
qemu_arch="$4"

urp="$(echo $rust_platform |tr - _)"
crp="$(echo $urp |tr '[a-z]' '[A-Z]')"
sysroot=/alpine/home/rust/sysroot-$os_arch

cat <<EOF >/environ
export AR_${urp}=${rust_platform}-ar
export CC_${urp}=${rust_platform}-gcc
export CXX_${urp}=${rust_platform}-g++

export CARGO_TARGET_${crp}_LINKER=/alpine/home/rust/bin/linkwrapper.sh
export CARGO_TARGET_${crp}_RUNNER=qemu-${qemu_arch}

export OPENSSL_DIR=${sysroot}/usr

export PATH=/alpine/home/rust/bin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

export PKG_CONFIG_ALLOW_CROSS=1
export PKG_CONFIG_LIBDIR=${sysroot}/usr/lib/pkgconfig
export PKG_CONFIG_SYSROOT_DIR=${sysroot}

export RUSTFLAGS="-L ${sysroot}/usr/lib -l static=expat -l static=bz2 -l static=uuid -l static=stdc++ -C target-feature=+crt-static"

export RUST_TEST_THREADS=1
EOF

rm -f "$0"  # self-destruct
