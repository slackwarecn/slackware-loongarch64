#!/bin/sh

# Copyright 2019  Patrick J. Volkerding, Sebeka, Minnesota, USA
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

# Pull a stable branch + patches
BRANCH=${1:-stable-2.0}

# Clear download area:
rm -rf lxc

# Clone repository:
git clone git://github.com/lxc/lxc

# checkout $BRANCH:
( cd lxc 
  git checkout $BRANCH || exit 1
)

LXC_MAJOR=$(cd lxc && grep "^m4_define(\[lxc_version_major" configure.ac | cut -f 2 -d ' ' | tr -d ')')
LXC_MINOR=$(cd lxc && grep "^m4_define(\[lxc_version_minor" configure.ac | cut -f 2 -d ' ' | tr -d ')')
LXC_MICRO=$(cd lxc && grep "^m4_define(\[lxc_version_micro" configure.ac | cut -f 2 -d ' ' | tr -d ')')
HEADISAT="$( cd lxc && git log -1 --format=%h )"
DATE="$( cd lxc && git log -1 --format=%cd --date=format:%Y%m%d )"

# Cleanup.  We're not packing up the whole git repo.
( cd lxc && find . -type d -name ".git*" -exec rm -rf {} \; 2> /dev/null )
mv lxc lxc-${LXC_MAJOR}.${LXC_MINOR}.${LXC_MICRO}_${HEADISAT}
tar cf lxc-${LXC_MAJOR}.${LXC_MINOR}.${LXC_MICRO}_${HEADISAT}.tar lxc-${LXC_MAJOR}.${LXC_MINOR}.${LXC_MICRO}_${HEADISAT}
xz -9 -f lxc-${LXC_MAJOR}.${LXC_MINOR}.${LXC_MICRO}_${HEADISAT}.tar
rm -rf lxc-${LXC_MAJOR}.${LXC_MINOR}.${LXC_MICRO}_${HEADISAT}
echo
echo "lxc branch $BRANCH with HEAD at $HEADISAT packaged as lxc-${LXC_MAJOR}.${LXC_MINOR}.${LXC_MICRO}_${HEADISAT}.tar.xz"
echo
