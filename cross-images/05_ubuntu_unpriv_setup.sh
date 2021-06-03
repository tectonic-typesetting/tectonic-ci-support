#! /bin/sh
# Copyright 2019-2021 The Tectonic Project
# Licensed under the MIT License.

set -x
set -eu  # no `-o pipefail` here

rust_platform="$1"
os_platform="$2"
toolprefix="$3"

cd
mkdir $HOME/bin

if [ "$rust_platform" = x86_64-unknown-linux-musl ] ; then
    # 2021 May: It seems that Rust 1.52 has started bundling more of its
    # own "crt" files, and we should no longer link with -lgcc, among
    # other changes. For our other platform that uses this framework,
    # arm-unknown-linux-musleabihf, we shouldn't change.
    force_crt=false
else
    force_crt=true
fi

for tmpl in toolwrapper.sh linkwrapper.sh ; do
    sed -e "s|@rust_platform@|$rust_platform|g" \
        -e "s|@os_platform@|$os_platform|g" \
        -e "s|@toolprefix@|$toolprefix|g" \
        -e "s|@force_crt@|$force_crt|g" \
        $tmpl.in >bin/$tmpl
    chmod +x bin/$tmpl
done

for tool in ar gcc g++ ld pkg-config ; do
    ln -s toolwrapper.sh $HOME/bin/wrapped-$tool
done

rm -f "$0"  # self-destruct
