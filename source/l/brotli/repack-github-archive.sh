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

CWD=$(pwd)
GITHUB_ARCHIVE=$(/bin/ls v[0-9]*.tar.gz)
OUTPUT_NAME=$(tar tvvf $GITHUB_ARCHIVE | head -n 1 | tr -d / | rev | cut -f 1 -d ' ' | rev)
OUTPUT_TIMESTAMP=$(tar tvvf $GITHUB_ARCHIVE | head -n 1 | tr -d / | rev | cut -f 2,3 -d ' ' | rev)

# Create a temporary extraction directory:
EXTRACT_DIR=$(mktemp -d)

# Extract, repack, compress, and fix timestamp:
( cd $EXTRACT_DIR
  tar xf $CWD/$GITHUB_ARCHIVE

  # This is excessive:
  rm -rf $OUTPUT_NAME/tests/*
  rm -f $OUTPUT_NAME/research/img/*
  rm -f $OUTPUT_NAME/java/org/brotli/integration/*.zip
  rm -f $OUTPUT_NAME/docs/brotli-comparison-study-2015-09-22.pdf

  tar cf $OUTPUT_NAME.tar $OUTPUT_NAME
  plzip -9 $OUTPUT_NAME.tar
  touch -d "$OUTPUT_TIMESTAMP" $OUTPUT_NAME.tar.lz
)

# Move the repacked archive here:
mv $EXTRACT_DIR/$OUTPUT_NAME.tar.lz .

# Remove the temporary directory:
rm -rf $EXTRACT_DIR
