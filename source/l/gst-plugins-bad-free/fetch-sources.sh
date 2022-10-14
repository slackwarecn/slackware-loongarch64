#!/bin/sh

# Copyright 2021  Patrick J. Volkerding, Sebeka, Minnesota, USA
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

# Call this script with the version of the gst-plugins-bad that you would
# like to fetch the sources for. This will fetch the base source from
# github, and then remove the non-free sources.
#
# Example:  VERSION=1.18.4 ./fetch-sources.sh

VERSION=${VERSION:-1.20.4}

rm -rf rm -rf gst-plugins-bad-free-$VERSION gst-plugins-bad-$VERSION

wget https://gstreamer.freedesktop.org/src/gst-plugins-bad/gst-plugins-bad-$VERSION.tar.xz

tar xvf gst-plugins-bad-$VERSION.tar.xz
rm -f gst-plugins-bad-$VERSION.tar.xz

./gst-p-bad-cleanup.sh gst-plugins-bad-$VERSION

mv gst-plugins-bad-$VERSION gst-plugins-bad-free-$VERSION

tar cf gst-plugins-bad-free-$VERSION.tar gst-plugins-bad-free-$VERSION
rm -rf gst-plugins-bad-free-$VERSION
plzip -9 gst-plugins-bad-free-$VERSION.tar
