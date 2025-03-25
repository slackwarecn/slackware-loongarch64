#!/bin/sh

# Copyright 2018, 2021, 2022, 2023, 2024  Patrick J. Volkerding, Sebeka, Minnesota, USA
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

# This script uses the SlackBuild scripts present here to build a
# complete set of kernel packages for the currently running architecture.
# It needs to be run once on 64-bit (uname -m = x86_64) and once on IA32
# (uname -m = i586 or i686).

# In spite of this being named "build-all-kernels.sh", you don't have to build
# all the packages or all the kernels that there are configs for. Set the
# variables below to tune this for your needs.

cd $(dirname $0) ; CWD=$(pwd)

BUILD=${BUILD:-1}

if [ -z "$VERSION" ]; then
  # Get the filename of the newest kernel tarball:
  KERNEL_SOURCE_FILE="$(/bin/ls -t linux-*.tar.?z | head -n 1 )"
  if echo $KERNEL_SOURCE_FILE | grep -q rc ; then # need to get rc versions a bit differently
    VERSION=$(/bin/ls -t linux-*.tar.?z | head -n 1 | rev | cut -f 3- -d . | cut -f 1,2 -d - | rev)
  else # normal release version
    VERSION=$(/bin/ls -t linux-*.tar.?z | head -n 1 | rev | cut -f 3- -d . | cut -f 1 -d - | rev)
  fi
fi
TMP=${TMP:-/tmp}

# If you don't want to build the kernel source package, set this to anything
# other than "yes":
BUILD_KERNEL_SOURCE_PACKAGE=${BUILD_KERNEL_SOURCE_PACKAGE:-yes}

# If you don't want to build the kernel package(s), set this to "no".
# If you only want to build one kernel package, set this to the name of the
# kernel (i.e. "generic").
# To build kernel packages for every available config, set to "yes".
BUILD_KERNEL_PACKAGE=${BUILD_KERNEL_PACKAGE:-yes}

# Build the kernel-headers package?
BUILD_KERNEL_HEADERS_PACKAGE=${BUILD_KERNEL_HEADERS_PACKAGE:-yes}

# Where should we find the kernel config files?
KERNEL_CONFIGDIR=${KERNEL_CONFIGDIR:-./kernel-configs}

# Make KERNEL_CONFIGDIR an absolute path:
KERNEL_CONFIGDIR=$(realpath $KERNEL_CONFIGDIR)
export KERNEL_CONFIGDIR

# By default, install the packages as we build them.
INSTALL_PACKAGES=${INSTALL_PACKAGES:-YES}

# By default, have the kernel package(s) generate an initrd upon installation:
AUTO_GENERATE_INITRD=${AUTO_GENERATE_INITRD:-YES}
export AUTO_GENERATE_INITRD

# By default, update the initrd. But if both INSTALL_PACKAGES and
# AUTO_GENERATE_INITRD are YES, then installing the kernel-generic package
# will generate the initrd, so no need to do this twice.
if [ "$INSTALL_PACKAGES" = "YES" -a "$AUTO_GENERATE_INITRD" = "YES" ]; then
  UPDATE_INITRD=${UPDATE_INITRD:-NO}
else
  UPDATE_INITRD=${UPDATE_INITRD:-YES}
fi

# Clean kernels before building them. Not doing so quit working some time
# after 4.19.x.
export KERNEL_CLEAN=YES

# Set this to true if you'd like to write the .config back to its source
# after running "make oldconfig". This ensures that the config file is the
# exact one used to build, and is sorted properly.
REGEN_CONFIG=${REGEN_CONFIG:-true}
export REGEN_CONFIG

# We'll figure this out if you build the kernel-source package, otherwise
# you better set it if it'll be needed to match the .config filename.
LOCALVERSION=${LOCALVERSION:-}

# A list of recipes for build may be passed in the $RECIPES variable, otherwise
# we have defaults based on uname -m:
if [ -z "$RECIPES" ]; then
  if uname -m | grep -wq x86_64 ; then
    RECIPES="x86_64"
  elif uname -m | grep -wq i.86 ; then
    RECIPES="IA32"
  else
    echo "Error: no build recipes available for $(uname -m)"
    exit 1
  fi
fi

# Main build loop:
for recipe in $RECIPES ; do

  # Build recipes are defined here. These will select the appropriate .config
  # files and package naming scheme, and define the output location.
  if [ "$recipe" = "x86_64" ]; then
    # Recipe for x86_64:
    export CONFIG_SUFFIX=".x64"
    OUTPUT=${OUTPUT:-${TMP}/output-x86_64-${VERSION}}
  elif [ "$recipe" = "IA32" ]; then
    # Recipe for IA32:
    export CONFIG_SUFFIX=".ia32"
    OUTPUT=${OUTPUT:-${TMP}/output-ia32-${VERSION}}
  else
    echo "Error: recipe ${recipe} not implemented"
    exit 1
  fi
  mkdir -p $OUTPUT

  echo
  echo "*************************************************"
  echo "* Building kernels for recipe ${recipe}..."
  echo "*************************************************"
  echo

  if [ "$BUILD_KERNEL_SOURCE_PACKAGE" = "yes" ]; then
    # Build kernel-source package.
    # Does a generic config file exist?
    # A generic config is defined here as one that does not use a LOCALVERSION.
    # If we don't see that, we'll look for this version plus any LOCALVERSION.
    # If that doesn't match, we take the newest config with the proper $CONFIG_SUFFIX.
    if [ -r $KERNEL_CONFIGDIR/config-${VERSION}${LOCALVERSION}${CONFIG_SUFFIX} ]; then
      KERNEL_CONFIG="config-${VERSION}${LOCALVERSION}${CONFIG_SUFFIX}"
    elif [ -r "$(/bin/ls -t $KERNEL_CONFIGDIR/config-${VERSION}*${CONFIG_SUFFIX} 2> /dev/null | head -n 1)" ]; then
      KERNEL_CONFIG="$(basename $(/bin/ls $KERNEL_CONFIGDIR/config-${VERSION}*${CONFIG_SUFFIX} 2> /dev/null | head -n 1))"
    elif [ -r "$(/bin/ls -t $KERNEL_CONFIGDIR/config-*${CONFIG_SUFFIX} 2> /dev/null | head -n 1)" ]; then
      KERNEL_CONFIG="$(basename $(/bin/ls $KERNEL_CONFIGDIR/config-*${CONFIG_SUFFIX} 2> /dev/null | head -n 1))"
    else
      echo "ERROR: no suitable config file found for ${CONFIG_SUFFIX}"
      exit 1
    fi
    export KERNEL_CONFIG
    # Build:
    KERNEL_SOURCE_PACKAGE_NAME=$(PRINT_PACKAGE_NAME=YES VERSION=$VERSION BUILD=$BUILD ./kernel-source.SlackBuild)
    VERSION=$VERSION BUILD=$BUILD ./kernel-source.SlackBuild
    mv ${TMP}/${KERNEL_SOURCE_PACKAGE_NAME} $OUTPUT || exit 1
    if [ "${INSTALL_PACKAGES}" = "YES" ]; then
      installpkg ${OUTPUT}/${KERNEL_SOURCE_PACKAGE_NAME} || exit 1
    fi
  else # otherwise, still stage the sources in $TMP/package-kernel-source:
    echo "Not building kernel-source package."
    sleep 2
    ONLY_STAGE_KERNEL_SOURCE=yes VERSION=$VERSION BUILD=$BUILD ./kernel-source.SlackBuild
  fi

  # Build kernel+modules package(s) for every config file with a matching $CONFIG_SUFFIX:
  for configfile in $KERNEL_CONFIGDIR/config-*${CONFIG_SUFFIX} ; do

    # Set the LOCALVERSION from this .config:
    LOCALVERSION=$(cat $configfile | grep "^CONFIG_LOCALVERSION=" | cut -f 2 -d = | tr -d \")

    # Set the name for this kernel.
    # If there's no LOCALVERSION, the name is "generic".
    # Otherwise, it is the LOCALVERSION minus any leading dash.
    if [ -z "$LOCALVERSION" ]; then
      KERNEL_NAME=generic
    else
      KERNEL_NAME=$LOCALVERSION
      # If there's a leading dash, remove it:
      if [ "$(echo $KERNEL_NAME | cut -b 1)" = "-" ]; then
        KERNEL_NAME="$(echo $KERNEL_NAME | cut -b 2-)"
      fi
    fi
    export KERNEL_NAME
 
    # Are we building this kernel?
    if [ ! "$BUILD_KERNEL_PACKAGE" = "yes" ]; then
      if [ ! "$BUILD_KERNEL_PACKAGE" = "$KERNEL_NAME" ]; then
        continue
      fi
    fi

    # We will build in the just-built kernel tree. First, let's put back the
    # symlinks:
    ( cd $TMP/package-kernel-source
      sh install/doinst.sh 2> /dev/null
    )

    # The initial release of any new kernel branch (e.g. 6.14.0) has a quirk -
    # The tarball will be labeled linux-6.14.tar.xz, but the kernel's version
    # in the Makefile will be 6.14.0. If we are regenerating kernel config
    # files, then we need to make sure that we're still using the proper
    # version number at this point:
    if [ ! -r "$KERNEL_CONFIGDIR/config-${VERSION}${LOCALVERSION}${CONFIG_SUFFIX}" -a -r "$KERNEL_CONFIGDIR/config-${VERSION}.0${LOCALVERSION}${CONFIG_SUFFIX}" ]; then
      VERSION=${VERSION}.0
    fi

    KERNEL_GENERIC_PACKAGE_NAME=$(PRINT_PACKAGE_NAME=YES KERNEL_SOURCE=$TMP/package-kernel-source/usr/src/linux KERNEL_CONFIG=$KERNEL_CONFIGDIR/config-${VERSION}${LOCALVERSION}${CONFIG_SUFFIX} CONFIG_SUFFIX=${CONFIG_SUFFIX} KERNEL_OUTPUT_DIRECTORY=$OUTPUT/kernels/${KERNEL_NAME}.s BUILD=$BUILD ./kernel-generic.SlackBuild)

    KERNEL_SOURCE=$TMP/package-kernel-source/usr/src/linux KERNEL_CONFIG=$KERNEL_CONFIGDIR/config-${VERSION}${LOCALVERSION}${CONFIG_SUFFIX} CONFIG_SUFFIX=${CONFIG_SUFFIX} KERNEL_OUTPUT_DIRECTORY=$OUTPUT/kernels/${KERNEL_NAME}.s BUILD=$BUILD ./kernel-generic.SlackBuild

    if [ -r ${TMP}/${KERNEL_GENERIC_PACKAGE_NAME} ]; then
      mv ${TMP}/${KERNEL_GENERIC_PACKAGE_NAME} $OUTPUT
    else
      echo "kernel-${KERNEL_NAME} build failed."
      exit 1
    fi
    if [ "${INSTALL_PACKAGES}" = "YES" ]; then
      installpkg ${OUTPUT}/${KERNEL_GENERIC_PACKAGE_NAME} || exit 1
    fi

  done # building kernel+modules package(s).

  if [ "$BUILD_KERNEL_HEADERS_PACKAGE" = "yes" ]; then
  # Build kernel-headers:
    KERNEL_HEADERS_PACKAGE_NAME=$(PRINT_PACKAGE_NAME=YES KERNEL_SOURCE=$TMP/package-kernel-source/usr/src/linux BUILD=$BUILD ./kernel-headers.SlackBuild)
    KERNEL_SOURCE=$TMP/package-kernel-source/usr/src/linux BUILD=$BUILD ./kernel-headers.SlackBuild
    if [ -r ${TMP}/${KERNEL_HEADERS_PACKAGE_NAME} ]; then
      mv ${TMP}/${KERNEL_HEADERS_PACKAGE_NAME} $OUTPUT
    else
      echo "kernel-headers build failed."
      exit 1
    fi
    if [ "${INSTALL_PACKAGES}" = "YES" ]; then
      upgradepkg --reinstall --install-new ${OUTPUT}/${KERNEL_HEADERS_PACKAGE_NAME} || exit 1
    fi
  fi

  # Update initrd:
  if [ "${UPDATE_INITRD}" = "YES" ]; then
    echo "Updating initrd with geninitrd..."
    /usr/sbin/geninitrd
  fi

  echo
  echo "${recipe} kernel packages done!"
  echo

done
