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

# Clear download area:
rm -rf shared-mime-info

# Clone repository:
git clone https://gitlab.freedesktop.org/xdg/shared-mime-info.git

VERSION=$(cd shared-mime-info && grep "^AC_INIT(\[shared-mime-info" configure.ac | cut -f 2 -d , | tr -d [ | tr -d ])

# Cleanup.  We're not packing up the whole git repo.
( cd shared-mime-info && find . -type d -name ".git*" -exec rm -rf {} \; 2> /dev/null )
( cd shared-mime-info/tests && rm -rf * )
mv shared-mime-info shared-mime-info-${VERSION}
rm -f shared-mime-info-${VERSION}.tar
tar cf shared-mime-info-${VERSION}.tar shared-mime-info-${VERSION}
rm -f shared-mime-info-${VERSION}.tar.lz
plzip -9 shared-mime-info-${VERSION}.tar
rm -rf shared-mime-info-${VERSION}
echo
echo "shared-mime-info packaged as shared-mime-info-${VERSION}.tar.lz"
echo
