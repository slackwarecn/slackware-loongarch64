#!/bin/sh
# Update the X font indexes:
if [ -x /usr/bin/mkfontdir -o -x /usr/X11R6/bin/mkfontdir ]; then
  mkfontdir usr/share/fonts/misc 2> /dev/null
fi
if [ -x /usr/bin/fc-cache ]; then
  /usr/bin/fc-cache -f 2> /dev/null
fi
