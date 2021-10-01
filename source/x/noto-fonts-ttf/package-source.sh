#!/bin/bash

# Copyright 2020, 2021  Patrick J. Volkerding, Sebeka, Minnesota, USA
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

# This pulls down the full noto-font archive from github and then packages
# the languages and weights that are most commonly used as well as the
# documentation into a "source" tarball. Note that since 100% of the contents
# of this are placed into the package .txz, there's not really any reason to
# keep the source archive after packaging it.

cd $(dirname $0) ; CWD=$(pwd)

VERSION=${VERSION:-v2017-10-24-phase3-second-cleanup}
PKGVER=${PKGVER:-$(echo $VERSION | cut -d v -f 2- | cut -d - -f 1-3 | tr -d -)}

# If both .ttc and .ttf formats exist, which to prefer:
GOOD_FORMAT=${GOOD_FORMAT:-ttf}

# Take non-Noto fonts?
PACKAGE_NON_NOTO=${PACKAGE_NON_NOTO:-NO}

# Package uncommonly used weights?
PACKAGE_UNCOMMON_WEIGHTS=${PACKAGE_UNCOMMON_WEIGHTS:-NO}

# Package unique unhinted fonts? This used to be needed solely for the symbol
# font, but there are hinted versions now. There are a few other fonts that are
# only available as unhinted though.
PACKAGE_UNHINTED_FONTS=${PACKAGE_UNHINTED_FONTS:-YES}

# Create a temporary extraction directory:
EXTRACT_DIR=$(mktemp -d)

( cd $EXTRACT_DIR
  # Does the source exist in $CWD? If so, just copy it here:
  if [ -r $CWD/${VERSION}.tar.gz ]; then
    cp -a $CWD/${VERSION}.tar.gz .
  else
    # Fetch the source:
    lftpget https://github.com/googlefonts/noto-fonts/archive/${VERSION}.tar.gz
  fi
  OUTPUT_TIMESTAMP=$(tar tvvf ${VERSION}.tar.gz | head -n 1 | tr -d / | rev | cut -f 2,3 -d ' ' | rev)
  tar xf ${VERSION}.tar.gz
  rm ${VERSION}.tar.gz
  mv *oto* noto-fonts
  # Remove the fonts listed in fonts-to-skip.txt:
  cat $CWD/fonts-to-skip.txt | while read line ; do
    if [ ! "$(echo $line | cut -b 1)" = "#" ]; then
      RMFONT="$(echo $line | tr -d " ")"
      rm -f --verbose noto-fonts/*hinted/NotoSans${RMFONT}-*.*
      rm -f --verbose noto-fonts/*hinted/NotoSerif${RMFONT}-*.*
    fi
  done
  # Remove UI fonts:
  rm -f --verbose noto-fonts/*hinted/Noto{Sans,Serif}*UI-*.{ttc,ttf}
  # Remove the unhinted font if a hinted version exists:
  for hintedfont in noto-fonts/hinted/* ; do
    rm -f --verbose noto-fonts/unhinted/$(basename $hintedfont)
  done
  # Remove duplicates:
  if [ "$GOOD_FORMAT" = "ttc" ]; then
    BAD_FORMAT="ttf"
  else
    BAD_FORMAT="ttc"
  fi 
  for file in noto-fonts/*hinted/*.${GOOD_FORMAT} ; do
    rm -f --verbose noto-fonts/*hinted/$(basename $file .${GOOD_FORMAT}).${BAD_FORMAT}
  done
  if [ "$PACKAGE_UNHINTED_FONTS" = "NO" ]; then
    rm -f --verbose noto-fonts/unhinted/*
  fi
  mkdir fonts
  mv noto-fonts/unhinted/* fonts
  mv noto-fonts/hinted/* fonts
  # Unless we selected to take non-Noto fonts (these are usually the ChromeOS
  # fonts), eliminate any fonts that do not begin with Noto:
  if [ "$PACKAGE_NON_NOTO" = "NO" ]; then
    mkdir fonts-tmp
    mv fonts/Noto* fonts-tmp
    rm -rf --verbose fonts
    mv fonts-tmp fonts
  fi
  if [ "$PACKAGE_UNCOMMON_WEIGHTS" = "NO" ]; then
    rm -f --verbose fonts/*{Condensed,SemiBold,Extra}*.{ttc,ttf}
  fi
  mkdir docs
  mv noto-fonts/{FAQ*,LICENSE*,NEWS*,README*,issue_*} docs
  rm -r noto-fonts
  # Fix permissions:
  find . -type f -exec chmod 644 {} \;
  # Create source archive:
  rm -f $CWD/noto-fonts-subset-${PKGVER}.tar*
  tar cvf $CWD/noto-fonts-subset-${PKGVER}.tar .
  plzip -9 -v $CWD/noto-fonts-subset-${PKGVER}.tar
  touch -d "$OUTPUT_TIMESTAMP" $CWD/noto-fonts-subset-${PKGVER}.tar.lz
)
  
# Cleanup:
rm -rf $EXTRACT_DIR
