#!/bin/bash

# Copyright 2020, 2021, 2024  Patrick J. Volkerding, Sebeka, Minnesota, USA
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

# This pulls down the noto-monthly-release from github and then packages
# the languages and weights that are most commonly used as well as the
# documentation into a "source" tarball. Note that since 100% of the contents
# of this are placed into the package .txz, there's not really any reason to
# keep the source archive after packaging it.

cd $(dirname $0) ; CWD=$(pwd)

VERSION=${VERSION:-2025.04.01}

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
  if [ -r $CWD/noto-monthly-release-${VERSION}.tar.gz ]; then
    cp -a $CWD/noto-monthly-release-${VERSION}.tar.gz .
  else
    # Fetch the source:
    lftpget https://github.com/notofonts/notofonts.github.io/archive/refs/tags/noto-monthly-release-${VERSION}.tar.gz
  fi
  OUTPUT_TIMESTAMP=$(tar tvvf noto-monthly-release-${VERSION}.tar.gz | head -n 1 | tr -d / | rev | cut -f 2,3 -d ' ' | rev)
  tar xf noto-monthly-release-${VERSION}.tar.gz
  rm noto-monthly-release-${VERSION}.tar.gz
  mv *oto* noto-fonts
  chmod 755 .

  # Save the documentation:
  mkdir docs
  ( cd noto-fonts
    mv README* LICENSE* ../docs
    mv fonts/LICENSE ../docs/LICENSE.SIL
  )

  # Remove the fonts listed in fonts-to-skip.txt:
  cat $CWD/fonts-to-skip.txt | while read line ; do
    if [ ! "$(echo $line | cut -b 1)" = "#" ]; then
      RMFONT="$(echo $line | tr -d " ")"
      rm -rf --verbose noto-fonts/fonts/NotoSans${RMFONT} noto-fonts/fonts/NotoSerif${RMFONT}
    fi
  done

  # Remove unpackaged fonts:
  rm -rf noto-fonts/fonts/*/unhinted/{otf,slim-variable-ttfi,variable,variable-ttf}
  # Remove the fonts listed in fonts-to-skip.txt:
  cat $CWD/fonts-to-skip.txt | while read line ; do
    if [ ! "$(echo $line | cut -b 1)" = "#" ]; then
      RMFONT="$(echo $line | tr -d " ")"
      rm -f --verbose noto-fonts/fonts/NotoSans${RMFONT}-*.*
      rm -f --verbose noto-fonts/fonts/NotoSerif${RMFONT}-*.*
    fi
  done
  # Remove UI fonts:
  find noto-fonts/fonts -name "NotoS*UI-*.ttf" -exec rm -f "{}" \;
  find noto-fonts/fonts -name "NotoS*UI-*.ttc" -exec rm -f "{}" \;
  # Remove OTF fonts:
  find noto-fonts/fonts -name otf -type d -exec rm -rf "{}" \;
  # Remove full fonts:
  find noto-fonts/fonts -name full -type d -exec rm -rf "{}" \;
  # Remove googlefonts fonts:
  find noto-fonts/fonts -name googlefonts -type d -exec rm -rf "{}" \;
  # Remove the unhinted font if a hinted version exists:
  for hintedfont in noto-fonts/fonts/*/hinted ; do
    rm -rf --verbose "$(echo $hintedfont | sed "s/hinted/unhinted/g")"
  done
  if [ "$PACKAGE_UNHINTED_FONTS" = "NO" ]; then
    rm -rf --verbose noto-fonts/fonts/*/unhinted
  fi
  # Unless we selected to take non-Noto fonts (these are usually the ChromeOS
  # fonts), eliminate any fonts that do not begin with Noto:
  if [ "$PACKAGE_NON_NOTO" = "NO" ]; then
    mkdir noto-fonts/fonts-tmp
    mv noto-fonts/fonts/Noto* noto-fonts/fonts-tmp
    rm -rf --verbose noto-fonts/fonts
    mv noto-fonts/fonts-tmp noto-fonts/fonts
  fi
  if [ "$PACKAGE_UNCOMMON_WEIGHTS" = "NO" ]; then
    rm -f noto-fonts/fonts/*/*hinted/ttf/*{Condensed,SemiBold,Extra}*.{ttc,ttf}
  fi
  # Move what remains to a common output directory:
  mkdir fonts
  mv --verbose noto-fonts/fonts/*/unhinted/ttf/* fonts
  mv --verbose noto-fonts/fonts/*/hinted/ttf/* fonts
  # Erase archive residue:
  rm -rf noto-fonts
  # Fix permissions:
  find . -type f -exec chmod 644 {} \;
  # Create source archive:
  rm -f $CWD/noto-fonts-subset-${VERSION}.tar*
  tar cvf $CWD/noto-fonts-subset-${VERSION}.tar .
  plzip -9 -v $CWD/noto-fonts-subset-${VERSION}.tar
  touch -d "$OUTPUT_TIMESTAMP" $CWD/noto-fonts-subset-${VERSION}.tar.lz
)
  
# Cleanup:
rm -rf $EXTRACT_DIR
