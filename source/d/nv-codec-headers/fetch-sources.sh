#!/bin/bash

VERSION=${VERSION:-12.1.14.0}

rm -rf nv-codec-headers-*.tar.?z*

git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git nv-codec-headers

cd nv-codec-headers
  git checkout n$VERSION
cd ..

mv nv-codec-headers nv-codec-headers-$VERSION

tar --exclude-vcs -cf nv-codec-headers-$VERSION.tar nv-codec-headers-$VERSION
plzip -9 nv-codec-headers-$VERSION.tar

rm -rf nv-codec-headers-$VERSION
