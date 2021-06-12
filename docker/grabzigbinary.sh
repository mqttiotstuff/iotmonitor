#!/bin/bash

VERSION=$1
COMMIT=$2

if [ -z "${COMMIT}"]
then
   echo "Using official build for zig"
   BASEFILENAME=zig-linux-x86_64-$VERSION
   DOWNLOADBASE=https://ziglang.org/download/$VERSION
else
   echo "Using nightly build releases for zig"
   BASEFILENAME=zig-linux-x86_64-$VERSION+$COMMIT
   DOWNLOADBASE=https://ziglang.org/builds
fi

wget $DOWNLOADBASE/$BASEFILENAME.tar.xz 
xz -d $BASEFILENAME.tar.xz
tar xvf $BASEFILENAME.tar

mv $BASEFILENAME zigbundle

