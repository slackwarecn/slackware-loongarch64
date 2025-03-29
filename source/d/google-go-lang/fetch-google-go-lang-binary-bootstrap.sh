#!/bin/bash

# If you do not already have a suitable version of Google Go installed,
# run this script to download a binary bootstrap. We'll use the same
# version as the sources found in this directory.

VERSION=${VERSION:-$(basename $(echo go*.src.tar.lz | cut -f 2 -d o) .src.tar.lz)}
if [ "$(uname -m)" = "x86_64" ]; then
  echo "Downloading binary bootstrap: https://go.dev/dl/go${VERSION}.linux-amd64.tar.gz"
  lftpget https://go.dev/dl/go${VERSION}.linux-amd64.tar.gz
elif [ "$(uname -m)" = "aarch64" ]; then
  echo "Downloading binary bootstrap: https://go.dev/dl/go${VERSION}.linux-arm64.tar.gz"
  lftpget https://go.dev/dl/go${VERSION}.linux-arm64.tar.gz
else
  echo "Downloading binary bootstrap: https://go.dev/dl/go${VERSION}.linux-386.tar.gz"
  lftpget https://go.dev/dl/go${VERSION}.linux-386.tar.gz
fi

