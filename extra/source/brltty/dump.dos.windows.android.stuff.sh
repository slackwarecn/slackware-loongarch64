#!/bin/sh
# Repacks the brltty tarball to remove the unneeded DOS/Windows stuff.

VERSION=${VERSION:-$(echo brltty-*.tar.?z* | rev | cut -f 3- -d . | cut -f 1 -d - | rev)}

tar xf brltty-${VERSION}.tar.xz || exit 1
mv brltty-${VERSION}.tar.xz brltty-${VERSION}.tar.xz.orig
rm brltty-${VERSION}/Android/Gradle/app/src/main/assets/UBraille.ttf
rm brltty-${VERSION}/Android/Gradle/gradle/wrapper/gradle-wrapper.jar
rm -r brltty-${VERSION}/Android/Gradle/app/src/*
rm -r brltty-${VERSION}/DOS
rm -r brltty-${VERSION}/Windows
tar cf brltty-${VERSION}.tar brltty-${VERSION}
rm -r brltty-${VERSION}
plzip -9 brltty-${VERSION}.tar
touch -r brltty-${VERSION}.tar.xz.orig brltty-${VERSION}.tar.lz
rm brltty-${VERSION}.tar.xz.orig
