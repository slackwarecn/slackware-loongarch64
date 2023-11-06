#!/bin/sh

# Copyright 2013, 2019, 2023  Patrick J. Volkerding, Sebeka, MN, USA
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

PKGNAM=exiv2
VERSION=${VERSION:-$(echo v*.tar.gz | cut -f 2- -d v | rev | cut -f 3- -d . | rev)}

if [ ! -r v${VERSION}.tar.gz ]; then
  echo "v${VERSION}.tar.gz does not exist. Exiting."
  exit 1
fi

OUTPUT_TIMESTAMP=$(tar tvvf v${VERSION}.tar.gz | head -n 1 | tr -d / | rev | cut -f 2,3 -d ' ' | rev)

rm -rf $PKGNAM-${VERSION}
tar xf v${VERSION}.tar.gz || exit 1
rm -rf $PKGNAM-${VERSION}/test/data/*
rm -rf $PKGNAM-${VERSION}/tests/bugfixes/*
rm -f $PKGNAM-${VERSION}.tar.lz
tar cf $PKGNAM-${VERSION}.tar $PKGNAM-${VERSION}
touch -d "$OUTPUT_TIMESTAMP" $PKGNAM-${VERSION}.tar
plzip -9 -v $PKGNAM-${VERSION}.tar
rm -rf $PKGNAM-${VERSION} v${VERSION}.tar.gz

echo "Repacking of v${VERSION}.tar.gz complete."

