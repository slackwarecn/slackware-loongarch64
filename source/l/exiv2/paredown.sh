#!/bin/sh

# Copyright 2013, 2019  Patrick J. Volkerding, Sebeka, MN, USA
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
VERSION=${VERSION:-$(echo $PKGNAM-*.tar.gz | rev | cut -f 3- -d . | cut -f 2 -d - | rev)}

if [ ! -r $PKGNAM-${VERSION}-Source.tar.gz ]; then
  echo "$PKGNAM-${VERSION}-Source.tar.gz does not exist. Exiting."
  exit 1
fi

touch -r $PKGNAM-${VERSION}-Source.tar.gz tmp-timestamp || exit 1

rm -rf $PKGNAM-${VERSION}-Source
tar xf $PKGNAM-${VERSION}-Source.tar.gz || exit 1
rm -rf $PKGNAM-${VERSION}-Source/test/data/*
rm -rf $PKGNAM-${VERSION}-Source/tests/bugfixes/*
rm -f $PKGNAM-${VERSION}-Source.tar.lz
tar cf $PKGNAM-${VERSION}-Source.tar $PKGNAM-${VERSION}-Source
touch -r tmp-timestamp $PKGNAM-${VERSION}-Source.tar
plzip -9 -v $PKGNAM-${VERSION}-Source.tar
rm -rf $PKGNAM-${VERSION}-Source tmp-timestamp

echo "Repacking of $PKGNAM-${VERSION}-Source.tar.lz complete."

