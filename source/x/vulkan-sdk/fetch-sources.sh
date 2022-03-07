#!/bin/sh

# Copyright 2017, 2018  Patrick J. Volkerding, Sebeka, Minnesota, USA
# Copyright 2021  Heinz Wiesinger, Amsterdam, The Netherlands
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

# Call this script with the version of the Vulkan-LoaderAndValidationLayers-sdk
# that you would like to fetch the sources for. This will fetch the SDK from
# github, and then look at the revisions listed in the external_revisions
# directory to fetch the proper glslang, SPIRV-Headers, and SPIRV-Tools.
#
# Example:  VERSION=1.1.92.1 ./fetch-sources.sh

VERSION=${VERSION:-latest}

get_known_good() {
JSON_PATH=$1
DEP=$2
KEY=$3

DEP_COMMIT=$(python3 - << EOF
import json
with open('$JSON_PATH') as f:
	known_good = json.load(f)
name = '$DEP'
headers = next(commit for commit in known_good['$KEY'] if commit['name'] == name)
print(headers['commit'])
EOF
)

echo $DEP_COMMIT
}

rm -f *.tar.lz

wget https://vulkan.lunarg.com/doc/view/$VERSION/linux/release_notes.html

VERSION=$(grep "Version" release_notes.html | grep "for Linux" | sed -e 's/<[^>]*>//g' | cut -d " " -f 2)

for i in $(grep "Repo:" release_notes.html | cut -d "\"" -f 2); do
  COMMIT=$(basename $i)
  REPO=$(echo $i | cut -d "/" -f 1-5)
  NAME=$(basename $REPO)
  echo ""
  echo "$NAME"
  echo ""

  # release notes for bugfix releases contain the repo list multiple times
  # only create tarballs for the most recent ones (on top)
  if ! [ -e $NAME.fetched ]; then
    git clone $REPO $NAME-$COMMIT
    cd $NAME-$COMMIT
      git reset --hard $COMMIT || git reset --hard origin/$COMMIT
      git submodule update --init --recursive
      git describe --tags > .git-version
    cd ..
    tar --exclude-vcs -cf $NAME-$COMMIT.tar $NAME-$COMMIT
    plzip -9 $NAME-$COMMIT.tar
    touch $NAME.fetched

    if [ "$NAME" = "glslang" -a ! -e SPIRV-Headers.fetched ]; then
      SPIRV_HEADERS_COMMIT=$(get_known_good glslang-$COMMIT/known_good.json spirv-tools/external/spirv-headers commits)

      git clone https://github.com/KhronosGroup/SPIRV-Headers.git SPIRV-Headers-$SPIRV_HEADERS_COMMIT
      cd SPIRV-Headers-$SPIRV_HEADERS_COMMIT
        git reset --hard $SPIRV_HEADERS_COMMIT || git reset --hard origin/$SPIRV_HEADERS_COMMIT
        git submodule update --init --recursive
        git describe --tags > .git-version
      cd ..
      tar --exclude-vcs -cf SPIRV-Headers-$SPIRV_HEADERS_COMMIT.tar SPIRV-Headers-$SPIRV_HEADERS_COMMIT
      plzip -9 SPIRV-Headers-$SPIRV_HEADERS_COMMIT.tar
      rm -rf SPIRV-Headers-$SPIRV_HEADERS_COMMIT
      touch SPIRV-Headers.fetched
    elif [ "$NAME" = "Vulkan-ValidationLayers" -a ! -e robin-hood-hashing.fetched ]; then
      ROBIN_HOOD_COMMIT=$(get_known_good Vulkan-ValidationLayers-$COMMIT/scripts/known_good.json robin-hood-hashing repos)

      git clone https://github.com/martinus/robin-hood-hashing.git robin-hood-hashing-$ROBIN_HOOD_COMMIT
      cd robin-hood-hashing-$ROBIN_HOOD_COMMIT
        git reset --hard $ROBIN_HOOD_COMMIT || git reset --hard origin/$ROBIN_HOOD_COMMIT
        git submodule update --init --recursive
        git describe --tags > .git-version
      cd ..
      tar --exclude-vcs -cf robin-hood-hashing-$ROBIN_HOOD_COMMIT.tar robin-hood-hashing-$ROBIN_HOOD_COMMIT
      plzip -9 robin-hood-hashing-$ROBIN_HOOD_COMMIT.tar
      rm -rf robin-hood-hashing-$ROBIN_HOOD_COMMIT
      touch robin-hood-hashing.fetched
    fi

    rm -rf $NAME-$COMMIT
  fi

done

if ! [ -e "Vulkan-ExtensionLayer.fetched" ]; then
    git clone https://github.com/KhronosGroup/Vulkan-ExtensionLayer.git Vulkan-ExtensionLayer-sdk-$VERSION
    cd Vulkan-ExtensionLayer-sdk-$VERSION
      git reset --hard sdk-$VERSION || git reset --hard origin/sdk-$VERSION || \
      git reset --hard sdk-$VERSION-TAG || git reset --hard origin/sdk-$VERSION-TAG || \
      git reset --hard sdk.$VERSION-TAG || git reset --hard origin/sdk.$VERSION-TAG
      git submodule update --init --recursive
      git describe --tags > .git-version
    cd ..
    tar --exclude-vcs -cf Vulkan-ExtensionLayer-sdk-$VERSION.tar Vulkan-ExtensionLayer-sdk-$VERSION
    plzip -9 Vulkan-ExtensionLayer-sdk-$VERSION.tar
    rm -rf Vulkan-ExtensionLayer-sdk-$VERSION
    touch Vulkan-ExtensionLayer.fetched
fi

echo $VERSION > VERSION

rm -f release_notes.html
rm -f *.fetched
