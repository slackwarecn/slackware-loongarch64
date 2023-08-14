#!/bin/bash

# Copyright 2020, 2021, 2022, 2023  Patrick J. Volkerding, Sebeka, Minnesota, USA
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

CWD=$(pwd)

# If no archive specified with $1, then look for a v[0-9]*.tar.gz styled tarball:
if [ ! -z $1 ]; then
  GITHUB_ARCHIVE=$1
else
  GITHUB_ARCHIVE=${GITHUB_ARCHIVE:-$(/bin/ls v[0-9]*.tar.gz 2> /dev/null)}
  if ! /bin/ls v[0-9]*.tar.gz 1> /dev/null 2> /dev/null ; then
    echo "ERROR: github archive not found"
    exit 1
  fi
fi

OUTPUT_NAME=$(tar tvvf $GITHUB_ARCHIVE | head -n 1 | tr -d / | rev | cut -f 1 -d ' ' | rev)
OUTPUT_TIMESTAMP=$(tar tvvf $GITHUB_ARCHIVE | head -n 1 | tr -d / | rev | cut -f 2,3 -d ' ' | rev)

# Create a temporary extraction directory:
EXTRACT_DIR=$(mktemp -d)

# Extract, repack, compress, and fix timestamp:
( cd $EXTRACT_DIR
  tar xf $CWD/$GITHUB_ARCHIVE
  # If this is a stupid archive with the name doubled up, fix that:
  if [ "$(echo $OUTPUT_NAME | cut -f 1 -d -)" = "$(echo $OUTPUT_NAME | cut -f 2 -d -)" ]; then
    echo -n "Fixing internal archive name $OUTPUT_NAME -> "
    OUTPUT_NAME="$(echo $OUTPUT_NAME | cut -f 2- -d -)"
    echo $OUTPUT_NAME
    mv * $OUTPUT_NAME
  elif [ "$(echo $OUTPUT_NAME | cut -f 1-2 -d -)" = "$(echo $OUTPUT_NAME | cut -f 3-4 -d -)" ]; then
    echo -n "Fixing internal archive name $OUTPUT_NAME -> "
    OUTPUT_NAME="$(echo $OUTPUT_NAME | cut -f 3- -d -)"
    echo $OUTPUT_NAME
    mv * $OUTPUT_NAME
  fi
  tar cf $OUTPUT_NAME.tar $OUTPUT_NAME
  plzip -9 $OUTPUT_NAME.tar
  touch -d "$OUTPUT_TIMESTAMP" $OUTPUT_NAME.tar.lz
)

# Move the repacked archive here:
mv $EXTRACT_DIR/*.tar.lz .

# Remove the temporary directory:
rm -rf $EXTRACT_DIR

# Remove the repo tarball:
rm -f $GITHUB_ARCHIVE
