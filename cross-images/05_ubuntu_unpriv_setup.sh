#! /bin/sh
# Copyright 2019 The Tectonic Project
# Licensed under the MIT License.

set -x
set -eu  # no `-o pipefail` here

rust_platform="$1"
os_platform="$2"
toolprefix="$3"

cd
mkdir $HOME/bin

for tmpl in toolwrapper.sh linkwrapper.sh ; do
    sed -e "s|@rust_platform@|$rust_platform|g" \
        -e "s|@os_platform@|$os_platform|g" \
        -e "s|@toolprefix@|$toolprefix|g" \
        $tmpl.in >bin/$tmpl
    chmod +x bin/$tmpl
done

for tool in ar gcc g++ ld pkg-config ; do
    ln -s toolwrapper.sh $HOME/bin/wrapped-$tool
done

rm -f "$0"  # self-destruct
