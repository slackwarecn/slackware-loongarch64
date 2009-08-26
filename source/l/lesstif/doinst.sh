#!/bin/sh
# Add the LessTif stuff to host.def if it isn't already there:
mkdir -p usr/lib/X11/config
touch usr/lib/X11/config/host.def
if ! grep LessTif usr/lib/X11/config/host.def 1> /dev/null 2> /dev/null ; then
  cat usr/lib/LessTif/config/host.def >> usr/lib/X11/config/host.def
fi
# Standard symlink creation section begins:
