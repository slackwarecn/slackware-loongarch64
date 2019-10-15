#!/bin/sh
# Only add the icecream directory to the PATH if we see that iceccd is
# supposed to be running on this machine:

if [ -x /etc/rc.d/rc.iceccd ]; then
  export PATH=/usr/libexec/icecc/bin:$PATH
fi
