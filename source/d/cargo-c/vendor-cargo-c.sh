#!/bin/bash

VERSION=${VERSION:-0.10.11}

if [ ! -r cargo-c-$VERSION.tar.gz ]; then
  echo "ERROR: cargo-c-$VERSION.tar.gz not found"
  exit 1
fi

# Let's get the timestamp correct as long as we're here:
touch -d "$(tar tvf cargo-c-$VERSION.tar.gz | head -n 1 | cut -d 0 -f 2- | cut -d ' ' -f 2-3)" cargo-c-$VERSION.tar.gz

# Clear any existing stuff out:
rm -rf cargo-c-$VERSION cargo-cargo-c-${VERSION}* *.tar

# Extract the original tarball:
tar xf cargo-c-$VERSION.tar.gz

# Vendor it:
cd cargo-c-$VERSION
  if ! [ -f /usr/bin/cargo-vendor-filterer ]; then
    echo "WARNING: Creating unfiltered vendor libs tarball!"
    cargo vendor
  else
    cargo vendor-filterer --platform="x86_64-unknown-linux-gnu" --platform="i686-unknown-linux-gnu"
  fi
cd ..
mv cargo-c-$VERSION cargo-c-vendored-$VERSION

# Tar up the vendored version:
tar cf cargo-c-vendored-$VERSION.tar cargo-c-vendored-$VERSION
plzip -9 cargo-c-vendored-$VERSION.tar

# Clean up:
rm -rf cargo-c-vendored-$VERSION
