#!/bin/bash

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

# Create a buildlist for make_world.sh from the most recent ChangeLog entry.
# Optionally pass the SECTIONS= variable to build the list from more sections
# than just the most recent one. For example, create a buildlist for the top
# two sections:
#
# CHANGELOG=/my/slackware/directory/ChangeLog.txt SECTIONS=2 buildlist-from-changelog.sh > buildlist
#
# Or, you can make a buildlist containing everything that is more recent than
# a certain timestamp in the ChangeLog. For example, to build everything that
# appears in the ChangeLog above the timestamp "Thu Apr 19 01:04:06 UTC 2018":
#
# CHANGELOG=/my/slackware/directory/ChangeLog.txt NEWERTHAN="Thu Apr 19 01:04:06 UTC 2018" buildlist-from-changelog.sh > buildlist
#
# If you've already upgraded to the official binaries listed in the ChangeLog,
# you should be able to recompile them locally in one pass without errors.
# Otherwise, if you are bootstrapping these updates it is recommended to build
# from the buildlist until everything is successfully built, and then one more
# time using FORCE_BUILD=yes.

# This should be the only option that you'll need to set to use a different
# ChangeLog. However, if the ChangeLog is not sitting in a full Slackware
# directory, you will need to provide a valid $SLACKROOT.
CHANGELOG=${CHANGELOG:-../ChangeLog.txt}

# Figure out the SLACKROOT from the ChangeLog path:
SLACKROOT=${SLACKROOT:-$(dirname $CHANGELOG)}

# Set the SLACKSRC directory:
SLACKSRC=${SLACKSRC:-${SLACKROOT}/source}

# Set the SLACKPKGS directory:
if [ -d ${SLACKROOT}/slackware64 ]; then
  SLACKPKGS=${SLACKPKGS:-${SLACKROOT}/slackware64}
elif [ -d ${SLACKROOT}/slackware ]; then
  SLACKPKGS=${SLACKPKGS:-${SLACKROOT}/slackware}
else
  echo "FATAL: package directory not found."
  exit 1
fi

# How many sections of the ChangeLog to output:
SECTIONS=${SECTIONS:-1}

# If we have $NEWERTHAN, we'll consider up to 30 sections before giving up if
# we don't see that timestamp:
if [ ! -z "$NEWERTHAN" ]; then
  SECTIONS=30
fi

# Find the short package name of a package or packages:
pkgname() {
  for package in $* ; do
    echo $(basename $package) | sed 's?-[^-]*-[^-]*-[^-]*$??'
  done
}

# Find a .txz package under $SLACKROOT, given a (possibly short) package name:
findpkg() {
  PKG_FOUND=false
  for testpkg in $SLACKPKGS/*/$(pkgname $1)*.txz ; do
    if [ "$(pkgname $1)" = "$(basename $testpkg | sed 's?-[^-]*-[^-]*-[^-]*$??')" ]; then
      echo $testpkg
      PKG_FOUND=true
      break
    fi
  done
  if [ "$PKG_FOUND" = "false" ]; then
    exit 1
  fi
}

# Make a temporary directory:
TMPDIR=$(mktemp -d)

# Output buildlist header:
if head -n 1 $CHANGELOG | grep -q " UTC 20" ; then
  if [ "$SECTIONS" = "1" ]; then
    echo "# buildlist generated from ChangeLog: $(head -n 1 $CHANGELOG)" > $TMPDIR/header
  else
    if [ -z "$NEWERTHAN" ]; then
      echo "# buildlist generated from ChangeLog ($SECTIONS sections): $(head -n 1 $CHANGELOG)" > $TMPDIR/header
    else
      echo "# buildlist generated from ChangeLog: $(head -n 1 $CHANGELOG), until timestamp $NEWERTHAN found" > $TMPDIR/header
    fi
  fi
else
  echo "# buildlist generated from ChangeLog (no timestamp - unclosed)" > $TMPDIR/header
fi
echo "#" >> $TMPDIR/header

SECFOUND=0
cat $CHANGELOG | while IFS= read -r line ; do
  if [ ! -z "$NEWERTHAN" ]; then
    if [ "$line" = "$NEWERTHAN" ]; then
      break
    fi
  fi
  echo "$line"
  if [ "$line" = "+--------------------------+" ]; then
    SECFOUND=$(expr $SECFOUND + 1)
    if [ "$SECTIONS" = "$SECFOUND" ]; then
      break
    fi
  fi
done | tac | while IFS= read -r line ; do
  #if echo "$line" | grep -q -e "^extra/" -e "^isolinux/" -e "^usb-and-pxe-installers/" -e "^kernels/" -e "^a/kernel-generic" -e "^a/kernel-huge" -e "^a/kernel-modules" -e "^d/kernel-headers" -e "^k/kernel-source" ; then
  if echo "$line" | grep -q -e "^extra/" -e "^isolinux/" -e "^usb-and-pxe-installers/" -e "^kernels/" ; then
    # We don't handle these files, but output it anyway (commented out):
    echo "# $line" >> $TMPDIR/packages
    if [ -r $TMPDIR/blurbcollect ]; then
      cat $TMPDIR/blurbcollect | tac >> $TMPDIR/packages
      rm -f $TMPDIR/blurbcollect
    fi
  elif echo "$line" | grep -q -e ":  Upgraded.$" -e ":  Rebuilt.$" -e ":  Added.$" ; then
    # Output the name of the matching built package under ${SLACKPKGS}.
    PACKAGE=$(findpkg $(echo $line | cut -f 1 -d :) | rev | cut -f 1,2 -d / | rev)
    if echo $PACKAGE | grep -q "^a/aaa_libraries" ; then
      # The aaa_libraries package must be build last, so put it in its own list:
      LISTPKG=aaa_libraries
    elif echo $PACKAGE | grep -q "^kde/" ; then
      # KDE packages should be built after all sobumps and normal packages:
      LISTPKG=kde
    elif echo $PACKAGE | grep -q "^d/perl" ; then
      # If we see perl, build it right after any sobumps:
      LISTPKG=perl
    elif echo $PACKAGE | grep -q -e "^a/kernel-generic" -e "^a/kernel-huge" -e "^a/kernel-modules" -e "^d/kernel-headers" -e "^k/kernel-source" ; then
      # All these kernel packages are no-ops for make_world.sh.
      LISTPKG=kernel
    else
      # All other packages go in the "packages" list:
      LISTPKG=packages
    fi
    # If the blurb mentions an .so-version bump, but that in a list to be
    # built first:
    if [ -r $TMPDIR/blurbcollect ]; then
      if cat $TMPDIR/blurbcollect | grep -q "Shared library .so-version bump." ; then
        # This package needs to be build first since others might depend on it.
        # Send it to the sobumps list:
        LISTPKG=sobumps
      fi
    fi
    if [ ! -z $PACKAGE ]; then
      echo "# $line" >> $TMPDIR/$LISTPKG
      if [ -r $TMPDIR/blurbcollect ]; then
        cat $TMPDIR/blurbcollect | tac >> $TMPDIR/$LISTPKG
        rm -f $TMPDIR/blurbcollect
      fi
      echo $PACKAGE >> $TMPDIR/$LISTPKG
    else
      echo "# NOT FOUND: $line" >> $TMPDIR/packages
      if [ -r $TMPDIR/blurbcollect ]; then
        cat $TMPDIR/blurbcollect | tac >> $TMPDIR/packages
        rm -f $TMPDIR/blurbcollect
      fi
    fi
  elif echo "$line" | grep -q ":  Removed.$" ; then
    # If the line is for a :  Removed. package, then output it to the list,
    # commented out:
    echo "# $line" >> $TMPDIR/packages
    if [ -r $TMPDIR/blurbcollect ]; then
      cat $TMPDIR/blurbcollect | tac >> $TMPDIR/packages
      rm -f $TMPDIR/blurbcollect
    fi
  elif echo "$line" | grep -q "^ " ; then
    echo "# $line" >> $TMPDIR/blurbcollect
  fi
done

# If $TMPDIR/kernel exists, put a header at the top and then comment the
# rest of it out:
if [ -r $TMPDIR/kernel ]; then
  cat << EOF > $TMPDIR/kernel.tmp
# Kernel packages are not handled by make_world.sh.
# To build these kernel packages, go to the source/k directory and run:
# ./build-all-kernels.sh
# If glibc appears in this buildlist, you may want to build the kernels
# before building this list to make sure that glibc is built against the
# kernel headers. This doesn't really matter most of the time, though.
# if gcc appears in this buildlist, then you *absolutely must* build the
# kernels after this buildlist is complete so that they are built with
# the new compiler.
EOF
  cat $TMPDIR/kernel | while IFS= read -r line ; do
    if [ ! "$(echo $line | cut -b 1)" = "#" ]; then
      echo "# $line" >> $TMPDIR/kernel.tmp
    else
      echo "$line" >> $TMPDIR/kernel.tmp
    fi
  done
  echo "#" >> $TMPDIR/kernel.tmp
  mv $TMPDIR/kernel.tmp $TMPDIR/kernel
fi

# Convert the buildlist from *.txz packages to SlackBuilds:
cat $TMPDIR/header $TMPDIR/kernel $TMPDIR/sobumps $TMPDIR/perl $TMPDIR/packages $TMPDIR/kde $TMPDIR/aaa_libraries 2> /dev/null | while IFS= read -r line ; do
  if echo "$line" | grep -q "^#" ; then
    # Commented out line:
    echo "$line" >> $TMPDIR/output
    continue
  fi
  SERIES=$(dirname $line)
  PACKAGE=$(pkgname $line)
  # Search SlackBuilds that start with that name:
  SEARCHFOUND=false
  for searchdir in $SLACKSRC/*/$(echo $PACKAGE | cut -f 1 -d -)* ; do
    testbuild=$searchdir/$(basename $searchdir).SlackBuild
    if [ ! -x $testbuild ]; then
      continue
    else
      for packagecompare in $(pkgname $(PRINT_PACKAGE_NAME=yes $testbuild | tr " " "\n")) ; do
        if [ "$PACKAGE" = "$packagecompare" ]; then
          SEARCHFOUND=true
          OUTPUTLINE=$(echo $testbuild | rev | cut -f 1-3 -d / | rev)
          if grep -q "^${OUTPUTLINE}$" $TMPDIR/output ; then
            echo "#${OUTPUTLINE}" >> $TMPDIR/output
          else
            echo "$OUTPUTLINE" >> $TMPDIR/output
          fi
          continue
        fi
      done
    fi
    if [ "$SEARCHFOUND" = "true" ]; then
      break
    fi
  done
  if [ "$SEARCHFOUND" = "true" ]; then
    continue
  fi
  # Handle special case of KDE package:
  if [ "$SERIES" = "kde" ]; then
    if [ -x $SLACKSRC/kde/kde.SlackBuild ]; then
      KDESB=kde/kde.SlackBuild
    elif [ -x $SLACKSRC/kde/kde/kde.SlackBuild ]; then
      KDESB=kde/kde/kde.SlackBuild
    else
      echo "# UNHANDLED: $line" >> $TMPDIR/output
      continue
    fi
    BUILDOPT="$(grep "^${PACKAGE}$" $(dirname $SLACKSRC/$KDESB)/modules/* | rev | cut -f 1 -d / | rev | head -n 1)"
    echo "$KDESB $BUILDOPT" >> $TMPDIR/output
    continue
  fi
  # Handle special case of aspell-en:
  if [ "$PACKAGE" = "aspell-en" ]; then
    echo "# To rebuild aspell-en, see:" >> $TMPDIR/output
    echo "#../extra/source/aspell-word-lists/aspell-dict.SlackBuild" >> $TMPDIR/output 
    continue
  fi
  # If the package is xorg-server-*, output commented buildscripts. We'll let
  # the next test handle the main xorg-server package.
  if [ "$PACKAGE" = "xorg-server-xnest" -o \
       "$PACKAGE" = "xorg-server-xvfb" -o \
       "$PACKAGE" = "xorg-server-xephyr" -o \
       "$PACKAGE" = "xorg-server-xwayland" ]; then
    echo "#x/x11/x11.SlackBuild xserver xorg-server" >> $TMPDIR/output
    continue
  fi
  # If we got here, it's either something built by x11.SlackBuild or it won't be found.
  # Handle special case of package built by x11.SlackBuild:
  if [ "$SERIES" = "x" ]; then
    SEARCHFOUND=false
    SRCDIR=$(basename $(dirname $(/bin/ls $SLACKSRC/x/x11/src/*/${PACKAGE}-* | head -n 1)))
    for packagecompare in $(pkgname $(PRINT_PACKAGE_NAME=yes $SLACKSRC/x/x11/x11.SlackBuild $SRCDIR $PACKAGE | tr " " "\n")) ; do
      if [ "$PACKAGE" = "$packagecompare" ]; then
        SEARCHFOUND=true
        OUTPUTLINE=$(echo $SLACKSRC/x/x11/x11.SlackBuild $SRCDIR $PACKAGE | rev | cut -f 1-3 -d / | rev)
        if grep -q "^${OUTPUTLINE}$" $TMPDIR/output ; then
          echo "#${OUTPUTLINE}" >> $TMPDIR/output
        else
          echo "$OUTPUTLINE" >> $TMPDIR/output
        fi
        continue
      fi
    done
  fi
  # A build script to build this package could not be found:
  if [ "$SEARCHFOUND" = "false" ]; then
    echo "# ERROR: NO BUILD SCRIPT FOUND FOR: $line" >> $TMPDIR/output
  fi
done

# Output:
cat $TMPDIR/output

rm -rf $TMPDIR
