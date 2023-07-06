#!/bin/sh

# Copyright 2023  Patrick J. Volkerding, Sebeka, Minnesota, USA
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

LUA_VERSION=5.4.4

# Clear download area:
rm -rf lua-*

# Download:
lftpget https://www.lua.org/ftp/lua-${LUA_VERSION}.tar.gz

# Extract:
tar xf lua-${LUA_VERSION}.tar.gz
rm lua-${LUA_VERSION}.tar.gz

# Apply pipewire patch:
lftpget https://wrapdb.mesonbuild.com/v2/lua_${LUA_VERSION}-1/get_patch
mv get_patch lua-patch.zip
unzip lua-patch.zip
rm lua-patch.zip

# Recompress:
tar cf lua-${LUA_VERSION}.tar lua-${LUA_VERSION}
plzip -9 lua-${LUA_VERSION}.tar
rm -r lua-${LUA_VERSION}

echo
echo "lua source downloaded and patched."
echo

