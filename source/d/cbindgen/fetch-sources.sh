#!/bin/bash

VERSION=${VERSION:-0.26.0}

rm -rf cbindgen-*.tar.?z cargo-cbindgen*

echo "Downloading cbindgen-$VERSION..."

wget --content-disposition "https://github.com/eqrion/cbindgen/archive/refs/tags/v$VERSION.tar.gz"

tar xf cbindgen-$VERSION.tar.gz

tar cf cbindgen-$VERSION.tar cbindgen-$VERSION

cd cbindgen-$VERSION

  if ! [ -f /usr/bin/cargo-vendor-filterer ]; then
    echo "WARNING: Creating unfiltered vendor libs tarball!"
    cargo vendor
  else
    cargo vendor-filterer --platform="x86_64-unknown-linux-gnu" --platform="i686-unknown-linux-gnu"
  fi

  mv vendor ../cargo-cbindgen-$VERSION
cd ..

tar cf cargo-cbindgen-$VERSION.tar cargo-cbindgen-$VERSION

plzip -9 cargo-cbindgen-$VERSION.tar
plzip -9 cbindgen-$VERSION.tar

rm -rf cbindgen-$VERSION
rm -rf cargo-cbindgen-$VERSION
rm -f cbindgen-$VERSION.tar.gz
