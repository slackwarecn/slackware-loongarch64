#!/bin/bash

# Copyright 2020  Patrick J. Volkerding, Sebeka, Minnesota, USA
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

# This pulls down the full noto-cjk archive from github and then packages the
# two font files that we want as well as the documentation into a "source"
# tarball. Note that since 100% of the contents of this are placed into the
# package .txz, there's not really any reason to keep the source archive after
# packaging it.

cd $(dirname $0) ; CWD=$(pwd)

VERSION=${VERSION:-2.001}

# Create a temporary extraction directory:
EXTRACT_DIR=$(mktemp -d)

# The Noto Sans CJK font types to package. Valid types are "all", or any of
# these (comma delimited): Black, Bold, DemiLight, Light, Medium, Regular, Thin.
SANS_TYPES=${SANS_TYPES:-all}

# The Noto Serif CJK font types to package. Valid types are "all", or any of
# these (comma delimited): Black, Bold, ExtraLight, Light, Medium, Regular, SemiBold.
SERIF_TYPES=${SERIF_TYPES:-Regular}

( cd $EXTRACT_DIR
  # Does the source exist in $CWD? If so, just copy it here:
  if [ -r $CWD/NotoSansV${VERSION}.tar.gz ]; then
    cp -a $CWD/NotoSansV${VERSION}.tar.gz .
  else
    # Fetch the source:
    lftpget https://github.com/googlefonts/noto-cjk/archive/NotoSansV${VERSION}.tar.gz
  fi
  OUTPUT_TIMESTAMP=$(tar tvvf NotoSansV${VERSION}.tar.gz | head -n 1 | tr -d / | rev | cut -f 2,3 -d ' ' | rev)
  tar xf NotoSansV${VERSION}.tar.gz
  rm NotoSansV${VERSION}.tar.gz
  mv *oto* noto-cjk
  rm -rf noto-cjk/.git
  mkdir -p tmp/fonts
  # Move the selected Noto Sans fonts to tmp/fonts:
  if [ "$SANS_TYPES" = "all" ]; then
    # Use the all-in-one font:
    mv --verbose noto-cjk/NotoSansCJK.ttc.zip tmp/fonts
  else
    echo $SANS_TYPES | tr "," "\n" | while read fonttype ; do
      mv --verbose noto-cjk/NotoSansCJK-${fonttype}.ttc tmp/fonts
    done
  fi
  # Move the selected Noto Serif fonts to tmp/fonts:
  if [ "$SERIF_TYPES" = "all" ]; then
    SERIF_TYPES="Black,Bold,ExtraLight,Light,Medium,Regular,SemiBold"
  fi 
  echo $SERIF_TYPES | tr "," "\n" | while read fonttype ; do
    mv --verbose noto-cjk/NotoSerifCJK-${fonttype}.ttc tmp/fonts
  done
  # Remove the fonts that we won't be packaging:
  rm noto-cjk/*.{ttc,otf,zip}
  # If we moved the zip file, now we have to extract the font:
  if [ -r tmp/fonts/NotoSansCJK.ttc.zip ]; then
    ( cd tmp/fonts
      unzip NotoSansCJK.ttc.zip NotoSansCJK.ttc
      rm NotoSansCJK.ttc.zip
    )
  fi
  # Copy the license, readmes:
  mkdir -p tmp/docs
  mv noto-cjk/* tmp/docs
  cd tmp
  # Fix permissions:
  find . -type f -exec chmod 644 {} \;
  # Create source archive:
  rm -f $CWD/NotoSansCJK_subset-${VERSION}.tar*
  tar cvf $CWD/NotoSansCJK_subset-${VERSION}.tar .
  plzip -9 -v $CWD/NotoSansCJK_subset-${VERSION}.tar
  touch -d "$OUTPUT_TIMESTAMP" $CWD/NotoSansCJK_subset-${VERSION}.tar.lz
)

# Cleanup:
rm -rf $EXTRACT_DIR
