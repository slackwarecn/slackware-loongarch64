#!/bin/sh

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

# Clear download area:
rm -rf woff2

# Clone repository:
git clone https://github.com/google/woff2.git

HEADISAT="$( cd woff2 && git log -1 --format=%h )"
DATE="$( cd woff2 && git log -1 --format=%ad --date=format:%Y%m%d )"

# Cleanup.  We're not packing up the whole git repo.
( cd woff2 && find . -type d -name ".git*" -exec rm -rf {} \; 2> /dev/null )
mv woff2 woff2-${DATE}_${HEADISAT}
tar cf woff2-${DATE}_${HEADISAT}.tar woff2-${DATE}_${HEADISAT}
plzip -9 woff2-${DATE}_${HEADISAT}.tar
rm -rf woff2-${DATE}_${HEADISAT}
touch -d "$DATE" woff2-${DATE}_${HEADISAT}.tar.lz
echo
echo "woff2 branch $BRANCH with HEAD at $HEADISAT packaged as woff2-${DATE}_${HEADISAT}.tar.lz"
echo
