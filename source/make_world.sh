#!/bin/bash
# Copyright 2018, 2022  Patrick J. Volkerding, Sebeka, Minnesota, USA
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

# make_world for Slackware: rebuilds all the SlackBuild scripts that are
# listed in the given build list.
# Each line needs to look like (for example, and without beginning with "# "):
# a/grep/grep.SlackBuild
# For x11/KDE packages, you may specify a specific package to be built using
# the arguments understood by the SlackBuild. For example:
# kde/kde.SlackBuild kdelibs:kdelibs
# Any line beginning with "#" will be skipped.

# WARNING: This script has the potential to mess up your system.
# It is not recommended to run this on a production machine.
# This script is meant to be used on a fully installed and updated system.
# Using it on a partially installed system may result in broken packages,
# packages with missing features, or build failures. If there are circular
# dependencies, more than one build may be needed to get a correct package.
#
# Slackware is not Gentoo.
# For Amusement Purposes Only.

# Not all SlackBuilds are compatible with this script. In order for a build
# script to work, it needs these features:
# 1) cd into the script directory when run i.e.: cd $(dirname $0) ; CWD=$(pwd)
# 2) Handle $TMP properly (less of an issue if you don't change $TMP)
# 3) Support output package name reporting with PRINT_PACKAGE_NAME=yes

cd $(dirname $0) ; CWD=$(pwd)
# Some SlackBuilds do not work (yet) with a different $TMP setting.
TMP=${TMP:-/tmp}
export TMP
# Where the SlackBuild script puts the built package (i.e., $TMP).
OUTPUT_LOCATION=${OUTPUT_LOCATION:-$TMP}
# Used for logs and lock files.
LOGDIR=$TMP/make_world
# Lockfiles. You might need to purge these before restarting a build.
mkdir -p $LOGDIR/lock

# Set a custom Slackware source directory. By default we assume we are already
# in the source directory.
SLACKWARE_SOURCE_DIRECTORY=${SLACKWARE_SOURCE_DIRECTORY:-}
if [ ! -z "$SLACKWARE_SOURCE_DIRECTORY" ]; then
  # Make sure this ends in '/':
  if [ ! "$(echo $SLACKWARE_SOURCE_DIRECTORY | rev | cut -b 1)" = "/" ]; then
    SLACKWARE_SOURCE_DIRECTORY="${SLACKWARE_SOURCE_DIRECTORY}/"
  fi
fi 

# To wipe build directories and package creation directories after each
# package is built, set this to anything other than "no". You might need
# to use this if you're short on build space. NOTE: if you use this
# feature, you can NOT run more than one copy of this script at the same
# time! It will wipe build trees for other packages before they can finish.
# Otherwise, file locking is used and you may run as many parallel copies
# of this script as you think will help to speed things along.
WIPE_AFTER_BUILD=${WIPE_AFTER_BUILD:-no}

# NOTE: In case kde.SlackBuild or x11.SlackBuild are used to build everything
# in one shot, it's safer to just let stuff be installed twice...
#
## This variable is used to tell x11.SlackBuild not to use upgradepkg on the
## built package since this script already does that:
#UPGRADE_PACKAGES=${UPGRADE_PACKAGES:-"no"}
#export UPGRADE_PACKAGES
#
## This variable is used to tell kde.SlackBuild not to use upgradepkg on the
## built package since this script already does that:
#UPGRADE=${UPGRADE:-"no"}
#export UPGRADE

# Be kind, don't hit control-c! If you do, you might leave broken packages,
# logfiles, and locks in $TMP that will cause problems for you later. If you're
# not in a huge hurry to quit, create this file (replace with $TMP if needed):
# /tmp/make_world/lock/abort
# This will cause all instances of make_world.sh to exit when they complete the
# task they are working on.
rm -f $LOGDIR/lock/abort

BUILDLIST=${BUILDLIST:-$LOGDIR/buildlist}
if [ ! -r $BUILDLIST -a ! -r ${BUILDLIST}.lock ]; then
  # The buildlist does not exist, so attempt to create one that builds
  # everything except for the kernels (the kernel scripts are not compatible
  # with make_world.sh, mostly because of the need to reboot the new kernel).
  touch ${BUILDLIST} ${BUILDLIST}.lock
  echo "Generating list of packages to build in ${BUILDLIST}..."
  for script in ${SLACKWARE_SOURCE_DIRECTORY}*/*/*.SlackBuild ; do
    # Only add the script if the SlackBuild name matches the directory name:
    if [ "$(basename $(echo $script | cut -f 1 -d ' ') .SlackBuild)" = "$(echo $(dirname $(echo $script | cut -f 1 -d ' ')) | rev | cut -f 1 -d / | rev)" ]; then
      # Don't try to build isapnptools on x86_64:
      if [ "$uname -m)" = "x86_64" -a "$(basename $(echo $script | cut -f 1 -d ' '))" = "isapnptools.SlackBuild" ]; then
        continue
      fi
      # Never try to build the devs package. It is obsolete and "upgrading" to it breaks
      # things on systems running udev.
      if [ "$(basename $(echo $script | cut -f 1 -d ' '))" = "devs.SlackBuild" ]; then
        continue
      fi
      echo $script >> $BUILDLIST
    fi
  done
  if [ -r ${SLACKWARE_SOURCE_DIRECTORY}kde/kde.SlackBuild ]; then
    echo "${SLACKWARE_SOURCE_DIRECTORY}kde/kde.SlackBuild" >> $BUILDLIST
  fi
  rm -f ${BUILDLIST}.lock
  # Set GEN_LIST_ONLY=yes if you'd like to exit after generating a build list.
  # You might want to do this to comment some build scripts out first, or if
  # you'd like to sort it into a "magic build order". ;-) This script is pretty
  # good at just brute-forcing things, though (with a few runs).
  if [ "$GEN_LIST_ONLY" = "yes" ]; then
    echo "Generated ${BUILDLIST}. Exiting."
    exit 0
  fi
fi
if [ -r ${BUILDLIST}.lock ]; then
  echo -n "Waiting for ${BUILDLIST}.lock to be removed..."
  while [ 0 ]; do
    if [ ! -r ${BUILDLIST}.lock ]; then
      break
    fi
    sleep 5
  done
  echo " done."
fi
echo "Using buildlist $BUILDLIST."

# To use shuffle mode (build packages in a random order each time through),
# pass SHUFFLE=yes (or anything other than "no") to this script.
SHUFFLE=${SHUFFLE:-no}
if [ "$SHUFFLE" = "no" ]; then
  SHUF=cat
else
  SHUF=shuf
fi

# To keep repeating the build list, set $REPEAT to anything other than "no":
REPEAT=${REPEAT:-no}

# To always rebuild a SlackBuild even if already built packages are found, set
# FORCE_BUILD=yes:
FORCE_BUILD=${FORCE_BUILD:-no}

# Function to do the build:
do_build() {
  if [ "$HAVE_GLOBAL_LOCK" = "true" ]; then
    # Wait for other builds to complete
    echo -n "have global lock, waiting for other builds to complete... "
    while [ 0 ]; do
      sleep 5
      if ! /bin/ls $LOGDIR/lock/*.lock 1> /dev/null 2> /dev/null ; then
        echo -n "done, continuing... "
        break
      fi
    done
  fi
  # If we're trying again, we don't want to leave a failure log in the logs
  # directory. But save it just in case...
  if [ -r $LOGDIR/$(basename $(echo $buildscript | cut -f 1 -d ' ')).log.failed ]; then
    mkdir -p $LOGDIR/faillog-backups
    mv $LOGDIR/$(basename $(echo $buildscript | cut -f 1 -d ' ')).log.failed $LOGDIR/faillog-backups
  fi
  $buildscript &> $LOGDIR/$(basename $(echo $buildscript | cut -f 1 -d ' ')).log
  if [ ! $? = 0 ]; then
    # Exit code from SlackBuild indicated an error:
    echo "$(PRINT_PACKAGE_NAME=foo $buildscript | head -n 1) failed to build."
    mv $LOGDIR/$(basename $(echo $buildscript | cut -f 1 -d ' ')).log $LOGDIR/$(basename $(echo $buildscript | cut -f 1 -d ' ')).log.failed
  elif [ ! -r $OUTPUT_LOCATION/$(PRINT_PACKAGE_NAME=foo $buildscript | head -n 1) ]; then
    # No error code returned from SlackBuild, but the package(s) were not found.
    # Possibly the SlackBuild doesn't honor $TMP, and a non-/tmp $TMP variable was set?
    echo "$(PRINT_PACKAGE_NAME=foo $buildscript | head -n 1) failed to build."
    mv $LOGDIR/$(basename $(echo $buildscript | cut -f 1 -d ' ')).log $LOGDIR/$(basename $(echo $buildscript | cut -f 1 -d ' ')).log.failed
  else
    # Figure out a progress report to include with the successful build message:
    cat $BUILDLIST | grep -v "^$" | grep -v "^#" | sort | uniq | cut -f 1 -d ' ' | rev | cut -f 1 -d / | rev > $LOGDIR/tmp-pkgs-to-build.$$
    # OK, we don't know if every *.log is actually finished if we're running
    # more than one make_world.sh, but whatever. It's an estimate.
    /bin/ls $LOGDIR/*.log | rev | cut -f 2,3 -d . | cut -f 1 -d / | rev > $LOGDIR/tmp-pkgs-built-or-building.$$
    NUMTOTAL="$(cat $LOGDIR/tmp-pkgs-to-build.$$ | wc -l)"
    NUMBUILT="$(grep -x -f $LOGDIR/tmp-pkgs-built-or-building.$$ $LOGDIR/tmp-pkgs-to-build.$$ | wc -l)"
    rm -f $LOGDIR/tmp-pkgs-to-build.$$ $LOGDIR/tmp-pkgs-built-or-building.$$
    echo "$(PRINT_PACKAGE_NAME=foo $buildscript | head -n 1) built successfully ($NUMBUILT/$NUMTOTAL)."
    for package in $(PRINT_PACKAGE_NAME=foo $buildscript) ; do
      upgradepkg --install-new --reinstall $OUTPUT_LOCATION/$package > /dev/null 2>&1
    done
    # The post-build cleanup is pretty sloppy. It will not clean up all of
    # the build-related residue, and it may possibly delete some things that
    # this script did not put there. It's also not compatible with running
    # more than one copy of make_world.sh simultaneously.
    # Think more than twice before using this.
    if [ ! "$WIPE_AFTER_BUILD" = "no" ]; then
      ( cd $TMP
        rm -f configure CMakeLists.txt
        for findconfigure in */configure ; do
          rm -rf "$(dirname $findconfigure)"
        done
        for findautogen in */autogen.sh ; do
          rm -rf "$(dirname $findautogen)"
        done
        for findcmake in */CMakeLists.txt ; do
          rm -rf "$(dirname $findcmake)"
        done
        for findmake in */Makefile ; do
          rm -rf "$(dirname $findmake)"
        done
        for findmeson in */meson.build ; do
          rm -rf "$(dirname $findmeson)"
        done
        for findpython in */setup.py ; do
          rm -rf "$(dirname $findpython)"
        done
        rm -rf package-*
      )
    fi
  fi
}

# Main loop:
while [ 0 ]; do
  # Skip any blank lines or lines in the buildlist that begin with #:
  cat $BUILDLIST | grep -v "^$" | grep -v "^#" | $SHUF | while read buildscript ; do
    if [ -r $LOGDIR/lock/abort ]; then
      echo "Exiting (abort requested)."
      exit 0
    fi
    # If there's a global lock, we have to wait for it to be released:
    if [ -r $LOGDIR/lock/lock.global ]; then
      HELD_BY="$(cat $LOGDIR/lock/lock.global)"
      echo -n "Waiting for global lock release (held by ${HELD_BY})... "
      while [ 0 ]; do
        sleep 10
        if [ ! -r $LOGDIR/lock/lock.global ]; then
          echo "released."
          break
        fi
        if [ ! "${HELD_BY}" = "$(cat $LOGDIR/lock/lock.global)" ]; then
          HELD_BY="$(cat $LOGDIR/lock/lock.global)"
          echo
          echo -n "Waiting for global lock release (held by ${HELD_BY})... "
        fi
      done
    fi
    echo -n "Working on $buildscript... "
    if [ -r $OUTPUT_LOCATION/$(PRINT_PACKAGE_NAME=foo $buildscript | head -n 1) -a $FORCE_BUILD = no ]; then
      echo "skipping because built package(s) were found."
      continue
    fi
    # Use flock to only allow one instance of this script to work on a given
    # SlackBuild script at a time. If the SlackBuild is already locked, we'll
    # just move on to the next one. Yes, you can run more than one copy of this
    # script at the same time to speed things up!
    #
    # See if we need a global lock. Some SlackBuilds are disruptive and other
    # builds should not take place until they have completed. For example, perl
    # removes itself from the system during the build. Assume that we need a
    # global lock for any package that uses removepkg, upgradepkg, slacktrack,
    # or trackbuild. Also, you may add the identifier REQUIRE_GLOBAL_LOCK
    # anywhere in a SlackBuild script to make it require the global lock.
    HAVE_GLOBAL_LOCK=false
    if grep -q -e removepkg -e upgradepkg -e slacktrack -e trackbuild -e REQUIRE_GLOBAL_LOCK $(dirname $(echo $buildscript | cut -f 1 -d ' '))/$(basename $(echo $buildscript | cut -f 1 -d ' ')) ; then
      # pkgtools, x11, and KDE all trigger the detection above, but none of them
      # really need the global lock. So only request the lock if the build
      # script is not one of those.
      if ! echo "$(basename $(echo $buildscript | cut -f 1 -d ' '))" | grep -q -x -e pkgtools.SlackBuild -e x11.SlackBuild -e kde.SlackBuild ; then
        HAVE_GLOBAL_LOCK=true
      fi
    fi
    if [ "$HAVE_GLOBAL_LOCK" = "true" ]; then
      ( flock 9 || exit 11
        echo $(basename $(echo $buildscript | cut -f 1 -d ' ')) >> $LOGDIR/lock/lock.global
        do_build
      ) 9> $LOGDIR/lock/lock.global
      # Remove lock file:
      rm -f $LOGDIR/lock/lock.global
    else
      ( flock -n 9 || exit 11
        do_build
      ) 9> $LOGDIR/lock/$(basename $(echo $buildscript | cut -f 1 -d ' ')).lock
      if [ $? = 11 ]; then
        echo "skipping (locked by another make_world.sh instance)."
        continue
      fi
      # Remove lock file:
      rm -f $LOGDIR/lock/$(basename $(echo $buildscript | cut -f 1 -d ' ')).lock
    fi
  done
  if [ "$REPEAT" = "no" ]; then
    break
  else
    # Figure out if we skipped everything and exit REPEAT mode if we did:
    cat $BUILDLIST | grep -v "^$" | grep -v "^#" | sort | uniq | cut -f 1 -d ' ' | rev | cut -f 1 -d / | rev > $LOGDIR/tmp-pkgs-to-build.$$
    /bin/ls $LOGDIR/*.log | rev | cut -f 2,3 -d . | cut -f 1 -d / | rev > $LOGDIR/tmp-pkgs-built-or-building.$$
    NUMTOTAL="$(cat $LOGDIR/tmp-pkgs-to-build.$$ | wc -l)"
    NUMBUILT="$(grep -x -f $LOGDIR/tmp-pkgs-built-or-building.$$ $LOGDIR/tmp-pkgs-to-build.$$ | wc -l)"
    rm -f $LOGDIR/tmp-pkgs-to-build.$$ $LOGDIR/tmp-pkgs-built-or-building.$$
    if [ "$NUMTOTAL" = "$NUMBUILT" ]; then
      echo "All packages have been built ($NUMBUILT/$NUMTOTAL). Exiting."
      break
    else
      echo "Repeating BUILDLIST since some packages are not built yet ($NUMBUILT/$NUMTOTAL complete)."
    fi
  fi
done
