#!/bin/sh

# Copyright 2024  Patrick J. Volkerding, Sebeka, Minnesota, USA
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


PKGNAM=luajit

# Pull a stable branch + patches
BRANCH=${1:-v2.1}

# Clear download area:
rm -rf ${PKGNAM}

# Clone repository:
git clone https://luajit.org/git/luajit.git

pushd luajit
  PATCH="$(git show -s --format=%ct)"
popd

# checkout $BRANCH:
( cd ${PKGNAM} 
  git checkout $BRANCH || exit 1
  # Add patch version:
  echo $PATCH > .relver
  # Use patchlevel, not ROLLING:
  sed -i "s/ROLLING/$PATCH/g" etc/luajit.pc src/luajit_rolling.h
)
MAJOR=$(grep majver= ${PKGNAM}/etc/luajit.pc | cut -f 2 -d =)
MINOR=$(grep minver= ${PKGNAM}/etc/luajit.pc | cut -f 2 -d =)
PATCH=$(grep relver= ${PKGNAM}/etc/luajit.pc | cut -f 2 -d =)
HEADISAT="$( cd ${PKGNAM} && git log -1 --format=%h )"
DATE="$( cd ${PKGNAM} && git log -1 --format=%cd --date=format:%Y%m%d )"
LONGDATE="$( cd ${PKGNAM} && git log -1 --format=%cd --date=format:%c )"
# Cleanup.  We're not packing up the whole git repo.
( cd ${PKGNAM} && find . -type d -name ".git*" -exec rm -rf {} \; 2> /dev/null )
mv ${PKGNAM} ${PKGNAM}-${MAJOR}.${MINOR}.${PATCH}
tar cf ${PKGNAM}-${MAJOR}.${MINOR}.${PATCH}.tar ${PKGNAM}-${MAJOR}.${MINOR}.${PATCH}
plzip -9 -f ${PKGNAM}-${MAJOR}.${MINOR}.${PATCH}.tar
rm -rf ${PKGNAM}-${MAJOR}.${MINOR}.${PATCH}
touch -d "$LONGDATE" ${PKGNAM}-${MAJOR}.${MINOR}.${PATCH}.tar.lz
echo
echo "${PKGNAM} branch $BRANCH with HEAD at $HEADISAT packaged as ${PKGNAM}-${MAJOR}.${MINOR}.${PATCH}.tar.lz"
echo
