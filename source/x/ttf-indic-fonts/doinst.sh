#!/bin/sh
# Update mkfontscale and mkfontdir:
if [ -x /usr/bin/mkfontdir ]; then
  mkfontscale usr/share/fonts/TTF 2> /dev/null
  mkfontdir usr/share/fonts/TTF 2> /dev/null
fi
# Update the X font indexes:
if [ -x /usr/bin/fc-cache ]; then
  /usr/bin/fc-cache -f 2> /dev/null
fi
