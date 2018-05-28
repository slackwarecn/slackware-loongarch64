#!/bin/sh

# Copyright 2018  Patrick J. Volkerding, Sebeka, Minnesota, USA
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

# Pull HEAD:
BRANCH=${1:-master}

# Clear download area:
rm -rf ast

# Clone repository:
git clone https://github.com/att/ast

# checkout $BRANCH:
( cd ast 
  git checkout $BRANCH || exit 1
)

HEADISAT="$( cd ast && git log -1 --format=%h )"
DATE="$( cd ast && git log -1 --format=%ad --date=format:%Y%m%d )"
# Cleanup.  We're not packing up the whole git repo.
( cd ast && find . -type d -name ".git*" -exec rm -rf {} \; 2> /dev/null )
# No need to package these:
( cd ast && rm -rf lib/package/tgz )
mv ast att-ast-${DATE}_${HEADISAT}
tar cf att-ast-${DATE}_${HEADISAT}.tar att-ast-${DATE}_${HEADISAT}
plzip -9 -n 6 -f att-ast-${DATE}_${HEADISAT}.tar
rm -rf att-ast-${DATE}_${HEADISAT}
echo
echo "ast branch $BRANCH with HEAD at $HEADISAT packaged as att-ast-${DATE}_${HEADISAT}.tar.lz"
echo
