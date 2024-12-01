#!/bin/sh

rm -f noto-emoji-subset-*

PKGNAM=noto-emoji
VERSION=${VERSION:-$(echo $PKGNAM-*.tar.lz | rev | cut -f 3- -d . | cut -f 1 -d - | rev)}

# Unpack original .tar.lz:
rm -rf ${PKGNAM}-${VERSION}
tar xf ${PKGNAM}-${VERSION}.tar.lz || exit 1

# Fix permissions:
cd ${PKGNAM}-${VERSION}
chown -R root:root .
find . \
  \( -perm 777 -o -perm 775 -o -perm 711 -o -perm 555 -o -perm 511 \) \
  -exec chmod 755 {} \+ -o \
  \( -perm 666 -o -perm 664 -o -perm 600 -o -perm 444 -o -perm 440 -o -perm 400 \) \
  -exec chmod 644 {} \+
cd ..

# Save the files that will be packaged:
mkdir -p ${PKGNAM}-subset-${VERSION}/fonts
cp -a -v ${PKGNAM}-${VERSION}/fonts/NotoColorEmoji.ttf ${PKGNAM}-subset-${VERSION}/fonts
( cd ${PKGNAM}-${VERSION}
  cp -a -v AUTHORS* BUILD* CONTRIBUTING* CONTRIBUTORS* fonts/LICENSE* README* ../${PKGNAM}-subset-${VERSION}
)

# Repack as .tar.lz:
rm -r ${PKGNAM}-${VERSION}
rm -f ${PKGNAM}-subset-${VERSION}.tar
tar cf ${PKGNAM}-subset-${VERSION}.tar ${PKGNAM}-subset-${VERSION}
rm -r ${PKGNAM}-subset-${VERSION}
touch -r ${PKGNAM}-${VERSION}.tar.lz ${PKGNAM}-subset-${VERSION}.tar
rm -f ${PKGNAM}-${VERSION}.tar.lz
plzip -9 ${PKGNAM}-subset-${VERSION}.tar
