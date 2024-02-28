#!/bin/sh
# Environment variables for the Qt package.
#
# It's best to use the generic directory to avoid
# compiling in a version-containing path:
if [ -d /usr/lib@LIBDIRSUFFIX@/qt6 ]; then
  QT6DIR=/usr/lib@LIBDIRSUFFIX@/qt6
else
  # Find the newest Qt directory and set $QT6DIR to that:
  for qtd in /usr/lib@LIBDIRSUFFIX@/qt6-* ; do
    if [ -d $qtd ]; then
      QT6DIR=$qtd
    fi
  done
fi
PATH="$PATH:$QT6DIR/bin"
export QT6DIR
# Unfortunately Chromium and derived projects (including QtWebEngine) seem
# to be suffering some bitrot when it comes to 32-bit support, so we are
# forced to disable the seccomp filter sandbox on 32-bit or else all of these
# applications crash. If anyone has a patch that gets these things running on
# 32-bit without this workaround, please let volkerdi or alienBOB know, or
# post your solution on LQ. Thanks. :-)
if file /bin/cat | grep -wq 32-bit ; then
  export QTWEBENGINE_CHROMIUM_FLAGS="--disable-seccomp-filter-sandbox"
fi
