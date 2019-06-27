#!/bin/sh
# Repacks the texlive tarball to remove unused sources.

VERSION=${VERSION:-$(echo texlive-*source.tar.?z* | rev | cut -f 2 -d - | cut -f 1 -d - | rev)}

tar xf texlive-${VERSION}-source.tar.xz || exit 1
mv texlive-${VERSION}-source.tar.xz texlive-${VERSION}-source.tar.xz.orig
( cd texlive-${VERSION}-source/libs && rm -rf cairo freetype2 gd gmp graphite2 harfbuzz mpfr icu libpng pixman potrace zlib )
( cd texlive-${VERSION}-source/utils && rm -rf asymptote )
( cd texlive-${VERSION}-source/texk && rm -rf dvisvgm )
( cd texlive-${VERSION}-source/texk/web2c && rm -rf alephdir )
( cd texlive-${VERSION}-source/texk/texlive && rm -rf w*_wrapper )
tar cf texlive-${VERSION}-source.tar texlive-${VERSION}-source
rm -r texlive-${VERSION}-source
xz -9 texlive-${VERSION}-source.tar
touch -r texlive-${VERSION}-source.tar.xz.orig texlive-${VERSION}-source.tar.xz
rm texlive-${VERSION}-source.tar.xz.orig
