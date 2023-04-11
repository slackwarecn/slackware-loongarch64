#!/bin/bash

#VERSION=$1
VERSION=0.65.0

rm -rf rust-bindgen-*.tar.?z cargo-rust-bindgen*

echo "Downloading rust-bindgen-$VERSION..."

wget --content-disposition "https://github.com/rust-lang/rust-bindgen/archive/refs/tags/v$VERSION.tar.gz"

tar xf rust-bindgen-$VERSION.tar.gz

tar cf rust-bindgen-$VERSION.tar rust-bindgen-$VERSION

cd rust-bindgen-$VERSION

  if ! [ -f /usr/bin/cargo-vendor-filterer ]; then
    echo "WARNING: Creating unfiltered vendor libs tarball!"
    cargo vendor
  else
    cargo vendor-filterer --platform="x86_64-unknown-linux-gnu" --platform="i686-unknown-linux-gnu"
  fi

  mv vendor ../cargo-rust-bindgen-$VERSION
cd ..

tar cf cargo-rust-bindgen-$VERSION.tar cargo-rust-bindgen-$VERSION

plzip -9 cargo-rust-bindgen-$VERSION.tar
plzip -9 rust-bindgen-$VERSION.tar

rm -rf rust-bindgen-$VERSION
rm -rf cargo-rust-bindgen-$VERSION
rm -f rust-bindgen-$VERSION.tar.gz
