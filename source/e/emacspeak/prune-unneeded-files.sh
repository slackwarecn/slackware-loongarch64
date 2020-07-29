#!/bin/sh
# Repacks the emacspeak tarball to remove some large/unused files.

PKGNAM=emacspeak
VERSION=${VERSION:-$(echo $PKGNAM-*.tar.bz2 | rev | cut -f 3- -d . | cut -f 1 -d - | rev)}

# Unpack original .tar.bz2:
rm -rf ${PKGNAM}-${VERSION}
tar xf ${PKGNAM}-${VERSION}.tar.bz2 || exit 1

# I have no idea what these are useful for. They aren't referenced anywhere
# else. If .json weren't such a bloated format I might keep them just in case,
# but let's strip them out for now. If it would be better to keep them (perhaps
# compressed as .gz or .xz), let me know.
( cd ${PKGNAM}-${VERSION}/etc && rm -f CompSciFact.json TVRaman.json UnixToolTip.json )

# Get rid of support files used to build .html:
( cd ${PKGNAM}-${VERSION}/etc
  for file in *.html ; do
    for supportfile in $(basename $file .html).* ; do
      if [ ! "$file" = "$supportfile" ]; then
        rm -f $supportfile
      fi
    done
  done
)

# Keep the last 6 NEWS files:
( cd ${PKGNAM}-${VERSION}/etc
  mkdir news-tmp
  mv $(ls -t NEWS* | head -n 6) news-tmp
  rm -f NEWS*
  mv news-tmp/* .
  rmdir news-tmp
)

# Drop the Makefile in etc/:
rm -f ${PKGNAM}-${VERSION}/etc/Makefile

# Repack as .tar.lz:
rm -f ${PKGNAM}-${VERSION}.tar
tar cf ${PKGNAM}-${VERSION}.tar ${PKGNAM}-${VERSION}
rm -f ${PKGNAM}-${VERSION}.tar.lz
plzip -9 ${PKGNAM}-${VERSION}.tar
touch -r ${PKGNAM}-${VERSION}.tar.bz2 ${PKGNAM}-${VERSION}.tar.lz
rm -r ${PKGNAM}-${VERSION}
