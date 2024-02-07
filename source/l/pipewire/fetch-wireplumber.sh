#!/bin/sh

# Copyright 2022, 2023, 2024  Patrick J. Volkerding, Sebeka, Minnesota, USA
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

# If pipewire has to pull from git, it always pulls git HEAD.
# But with 0.4.81, support for elogind seems broken, although it is
# detected and linked to.
# So we'll stick with this until a newer version can be tested and found
# to work with bluetooth.
CHECKOUT=${CHECKOUT:-0.4.17}

# Clear download area:
rm -rf wireplumber wireplumber.tar wireplumber.tar.lz

# Clone repository:
git clone https://gitlab.freedesktop.org/pipewire/wireplumber.git
( cd wireplumber ; git checkout $CHECKOUT )

# Cleanup.  We're not packing up the whole git repo.
rm -rf wireplumber/.git*
tar cf wireplumber.tar wireplumber
plzip -9 -n 6 -f wireplumber.tar
rm -rf wireplumber
echo
echo "wireplumber source repo packaged"
echo
