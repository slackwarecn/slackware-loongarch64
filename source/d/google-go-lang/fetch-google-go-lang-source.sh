#!/bin/bash

# Fetch the Google Go source and convert it to .lz:

VERSION=1.24.1
rm -f go${VERSION}.src.tar.gz
lftpget https://storage.googleapis.com/golang/go${VERSION}.src.tar.gz
gzip -d go${VERSION}.src.tar.gz
plzip -9 go${VERSION}.src.tar
