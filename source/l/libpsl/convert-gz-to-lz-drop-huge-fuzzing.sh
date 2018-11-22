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

PKGNAM=libpsl
VERSION=${VERSION:-$(echo $PKGNAM-*.tar.?z | rev | cut -f 3- -d . | cut -f 1 -d - | rev)}
rm -rf ${PKGNAM}-${VERSION} ${PKGNAM}-${VERSION}.tar ${PKGNAM}-${VERSION}.tar.lz
tar xf ${PKGNAM}-${VERSION}.tar.gz || exit 1
rm -rf ${PKGNAM}-${VERSION}/fuzz/libpsl_*{.in,.repro,.dict}
tar cf ${PKGNAM}-${VERSION}.tar ${PKGNAM}-${VERSION}
plzip -9 ${PKGNAM}-${VERSION}.tar
rm -rf ${PKGNAM}-${VERSION}
touch -r ${PKGNAM}-${VERSION}.tar.gz ${PKGNAM}-${VERSION}.tar.lz
