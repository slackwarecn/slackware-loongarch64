#!/bin/sh
# KDE additions:
KDEDIRS=/usr
export KDEDIRS
PATH="$PATH:/usr/lib/kf5:/usr/lib/kde4/libexec"
export PATH
if [ ! "$XDG_CONFIG_DIRS" = "" ]; then
  XDG_CONFIG_DIRS=$XDG_CONFIG_DIRS:/etc/kde/xdg
else
  XDG_CONFIG_DIRS=/etc/xdg:/etc/kde/xdg
fi
if [ "$XDG_RUNTIME_DIR" = "" ]; then
  # Using /run/user would be more in line with XDG specs, but in that case
  # we should mount /run as tmpfs and add this to the Slackware rc scripts:
  # mkdir /run/user ; chmod 1777 /run/user
  # XDG_RUNTIME_DIR=/run/user/$USER
  XDG_RUNTIME_DIR=/tmp/xdg-runtime-$USER
  mkdir -p $XDG_RUNTIME_DIR
  chown $USER $XDG_RUNTIME_DIR
  chmod 700 $XDG_RUNTIME_DIR
fi
export XDG_CONFIG_DIRS XDG_RUNTIME_DIR

