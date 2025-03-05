#!/bin/bash

VERSION=${VERSION:-0.25.3}

if [ ! -r v$VERSION.tar.gz ]; then
  echo "ERROR: v$VERSION.tar.gz not found"
  exit 1
fi

# Let's get the timestamp correct as long as we're here:
touch -d "$(tar tvf v$VERSION.tar.gz | head -n 1 | cut -d 0 -f 2- | cut -d ' ' -f 2-3)" v$VERSION.tar.gz

# Clear any existing stuff out:
rm -rf tree-sitter-$VERSION tree-sitter-${VERSION}* *.tar

# Extract the original tarball:
tar xf v$VERSION.tar.gz

# Vendor it:
cd tree-sitter-$VERSION
  if ! [ -f /usr/bin/cargo-vendor-filterer ]; then
    echo "WARNING: Creating unfiltered vendor libs tarball!"
    cargo vendor
  else
    cargo vendor-filterer --platform="x86_64-unknown-linux-gnu" --platform="i686-unknown-linux-gnu"
  fi
cd ..
mv tree-sitter-$VERSION tree-sitter-vendored-$VERSION

# Tar up the vendored version:
tar cf tree-sitter-vendored-$VERSION.tar tree-sitter-vendored-$VERSION
plzip -9 tree-sitter-vendored-$VERSION.tar

# Clean up:
rm -rf tree-sitter-vendored-$VERSION
