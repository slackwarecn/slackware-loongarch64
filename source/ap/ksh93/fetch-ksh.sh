#!/bin/sh

# Copyright 2018, 2020, 2021  Patrick J. Volkerding, Sebeka, Minnesota, USA
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

set -o errexit

# Use 1.0 (ksh93u+m) branch. Verify first that there's no better branch with
# "git branch -a" in the unpruned repo.
BRANCH=${1:-1.0}

# Clear download area:
rm -rf ksh

# Clone repository and check out $BRANCH:
git clone -b "$BRANCH" https://github.com/ksh93/ksh

HEADISAT=$( cd ksh && git log -1 --format=%h )
DATE="$( cd ksh && git log -1 --format=%cd --date=format:%Y%m%d )"
LONGDATE="$( cd ksh && git log -1 --format=%cd --date=format:%c )"
VERSION=$(sed -n '/^#define SH_RELEASE_SVER/ { s/.*"\(.*\)".*/\1/; s/-/_/g; p; }' ksh/src/cmd/ksh93/include/version.h)
# Cleanup.  We're not packing up the whole git repo.
rm -rf ksh/.git*
mv ksh "ksh-${BRANCH}_${DATE}_${HEADISAT}"
tar cf "ksh-${BRANCH}_${DATE}_${HEADISAT}.tar" "ksh-${BRANCH}_${DATE}_${HEADISAT}"
plzip -9 -n 6 -f "ksh-${BRANCH}_${DATE}_${HEADISAT}.tar"
touch -d "$LONGDATE" ksh-${BRANCH}_${DATE}_${HEADISAT}.tar.lz
rm -rf "ksh-${BRANCH}_${DATE}_${HEADISAT}"
echo
echo "ksh branch $BRANCH with HEAD at $HEADISAT packaged as ksh-${BRANCH}_${DATE}_${HEADISAT}.tar.lz"
echo
