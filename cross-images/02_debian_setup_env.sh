#! /bin/bash
# Copyright 2019 The Tectonic Project
# Licensed under the MIT License.

set -xeuo pipefail

urp="$(echo $rust_platform |tr - _)"
crp="$(echo $urp |tr '[a-z]' '[A-Z]')"

RUSTFLAGS="-L /usr/lib/${debian_platform}"

cat <<EOF >/environ
export AR_${urp}="${debian_platform}-ar"
export CC_${urp}="${debian_platform}-gcc"
export CXX_${urp}="${debian_platform}-g++"
export CARGO_TARGET_${crp}_LINKER="${debian_platform}-g++"

export OPENSSL_LIB_DIR=/usr/lib/${debian_platform}
export OPENSSL_INCLUDE_DIR=/usr/include
export PKG_CONFIG_LIBDIR=/usr/lib/${debian_platform}/pkgconfig

export RUSTFLAGS="$RUSTFLAGS"
export PKG_CONFIG_ALLOW_CROSS=1
export RUST_TEST_THREADS=1
export RUST_BACKTRACE=1
export TECTONIC_PKGCONFIG_FORCE_SEMI_STATIC=1
EOF

# The OpenSSL includes are split between /usr/include (platform-independent)
# and /usr/include/${debian_platform} (platform-dependent). I don't believe
# that openssl-sys is smart enough to deal with that well. Since we're in a
# container, just hack it:
cp /usr/include/${debian_platform}/openssl/*.h /usr/include/openssl/

if [ $qemu_arch != native ] ; then
    cat <<EOF >>/environ
export CARGO_TARGET_${crp}_RUNNER=qemu-${qemu_arch}-static
EOF
fi

rm -f "$0"  # self-destruct
