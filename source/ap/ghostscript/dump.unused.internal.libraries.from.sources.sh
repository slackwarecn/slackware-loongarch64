#!/bin/sh
# Repacks the ghostscript tarball to remove old unmaintained libraries.
# The SlackBuild would remove them before building anyway, but this way
# we don't waste bandwidth and storage on useless junk.

VERSION=${VERSION:-$(echo ghostscript-*.tar.?z* | rev | cut -f 3- -d . | cut -f 1 -d - | rev)}

tar xf ghostscript-${VERSION}.tar.xz || exit 1
mv ghostscript-${VERSION}.tar.xz ghostscript-${VERSION}.tar.xz.orig
( cd ghostscript-${VERSION} && rm -rf freetype jpeg lcms2 libpng libtiff png tiff zlib )
tar cf ghostscript-${VERSION}.tar ghostscript-${VERSION}
rm -r ghostscript-${VERSION}
xz -9 ghostscript-${VERSION}.tar
touch -r ghostscript-${VERSION}.tar.xz.orig ghostscript-${VERSION}.tar.xz
rm ghostscript-${VERSION}.tar.xz.orig
