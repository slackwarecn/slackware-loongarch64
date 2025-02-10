#!/bin/bash

VERSION=${VERSION:-2.59.2}

if [ ! -r librsvg-$VERSION.tar.xz ]; then
  echo "ERROR: librsvg-$VERSION.tar.xz not found"
  exit 1
fi

# Clear any existing stuff out:
rm -rf librsvg-$VERSION librsvgargo-c-${VERSION}* *.tar

# Extract the original tarball:
tar xf librsvg-$VERSION.tar.xz

# Vendor it:
cd librsvg-$VERSION
  if ! [ -f /usr/bin/cargo-vendor-filterer ]; then
    echo "WARNING: Creating unfiltered vendor libs tarball!"
    cargo vendor
  else
    cargo vendor-filterer --platform="x86_64-unknown-linux-gnu" --platform="i686-unknown-linux-gnu"
  fi
cd ..
mv librsvg-$VERSION librsvg-vendored-$VERSION

# Tar up the vendored version:
tar cf librsvg-vendored-$VERSION.tar librsvg-vendored-$VERSION
plzip -9 librsvg-vendored-$VERSION.tar

# Clean up:
rm -rf librsvg-vendored-$VERSION
