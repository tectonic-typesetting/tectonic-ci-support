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

if [ $os_arch = native ] ; then
    sysroot=/alpine
else
    sysroot=/alpine/home/rust/sysroot-$os_arch
fi

RUSTFLAGS="-C target-feature=+crt-static -L ${sysroot}/usr/lib"

for tectonic_implicit_dep in bz2 expat uuid stdc++ ; do
    RUSTFLAGS="$RUSTFLAGS -l static=${tectonic_implicit_dep}"
done

if [ "$rust_platform" = aarch64-unknown-linux-musl ] ; then
    # Monkey-see, monkey-do workaround for
    # https://github.com/rust-lang/rust/issues/46651 copied from `cross`.
    RUSTFLAGS="$RUSTFLAGS -C link-arg=-lgcc"
fi

if [ "$rust_platform" = arm-unknown-linux-musleabihf ] ; then
    # 2021 Jan: workaround for
    # https://github.com/rust-lang/compiler-builtins/issues/353 . -lgcc is
    # already at the end of the link line, which is supposed to prevent the
    # error, so I guess we have to force the issue.
    RUSTFLAGS="$RUSTFLAGS -C link-arg=-Wl,--allow-multiple-definition"
fi

cat <<EOF >/environ
export PATH=/alpine/home/rust/bin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

export AR_${urp}=wrapped-ar
export CC_${urp}=wrapped-gcc
export CXX_${urp}=wrapped-g++
export CARGO_TARGET_${crp}_LINKER=/alpine/home/rust/bin/linkwrapper.sh

export OPENSSL_DIR=${sysroot}/usr
export PKG_CONFIG_LIBDIR=${sysroot}/usr/lib/pkgconfig
export PKG_CONFIG_SYSROOT_DIR=${sysroot}

export RUSTFLAGS="$RUSTFLAGS"
export PKG_CONFIG_ALLOW_CROSS=1
export RUST_TEST_THREADS=1
export RUST_BACKTRACE=1
EOF

if [ $qemu_arch != native ] ; then
    cat <<EOF >>/environ
export CARGO_TARGET_${crp}_RUNNER=qemu-${qemu_arch}
EOF
fi

rm -f "$0"  # self-destruct
