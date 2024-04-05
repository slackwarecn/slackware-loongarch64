#!/bin/bash

VERSION=${VERSION:-0.5.14}

rm -rf cargo-vendor-filterer-*.tar.?z cargo-cargo-vendor-filterer*

echo "Downloading cargo-vendor-filterer-$VERSION..."

wget --content-disposition "https://github.com/coreos/cargo-vendor-filterer/archive/refs/tags/v$VERSION.tar.gz"

tar xf cargo-vendor-filterer-$VERSION.tar.gz

tar cf cargo-vendor-filterer-$VERSION.tar cargo-vendor-filterer-$VERSION

cd cargo-vendor-filterer-$VERSION

  # Configure cargo-vendor-filterer
  cat << EOF >> Cargo.toml
[package.metadata.vendor-filter]
platforms = ["x86_64-unknown-linux-gnu", "i686-unknown-linux-gnu"]
all-features = true
exclude-crate-paths = [
  { name = "openssl-src", exclude = "openssl" },
]
EOF


  if ! [ -f /usr/bin/cargo-vendor-filterer ]; then
    echo "WARNING: Creating unfiltered vendor libs tarball!"
    cargo vendor
  else
    cargo vendor-filterer
  fi

  mv vendor ../cargo-cargo-vendor-filterer-$VERSION
cd ..

tar cf cargo-cargo-vendor-filterer-$VERSION.tar cargo-cargo-vendor-filterer-$VERSION

plzip -9 cargo-cargo-vendor-filterer-$VERSION.tar
plzip -9 cargo-vendor-filterer-$VERSION.tar

rm -rf cargo-vendor-filterer-$VERSION
rm -rf cargo-cargo-vendor-filterer-$VERSION
rm -f cargo-vendor-filterer-$VERSION.tar.gz
