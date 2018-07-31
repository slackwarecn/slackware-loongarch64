#!/bin/sh

# Copyright 2018  Patrick J. Volkerding, Sebeka, Minnesota, USA
# All rights reserved.
#
# Redistribution and use of this script, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this script must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
#  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
#  EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
#  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
#  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

cd $(dirname $0) ; CWD=$(pwd)

PKGNAM=fuse
VERSION=${VERSION:-$(echo $PKGNAM-*.tar.?z | rev | cut -f 3- -d . | cut -f 1 -d - | rev)}
rm -rf fuse-${VERSION} fuse-${VERSION}.tar fuse-${VERSION}.tar.lz
gpg --verify fuse-${VERSION}.tar.gz.asc || exit 1
tar xf fuse-${VERSION}.tar.gz || exit 1
rm -f fuse-${VERSION}/doc/html/*
tar cf fuse-${VERSION}.tar fuse-${VERSION}
plzip -9 fuse-${VERSION}.tar
rm -rf fuse-${VERSION}
