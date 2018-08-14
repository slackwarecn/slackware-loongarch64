#!/bin/sh
# Only add the icecream directory to the PATH if we see that icecc-scheduler
# and/or iceccd are running on this machine:

if /usr/bin/pgrep --ns $$ -f "^/usr/sbin/icecc-scheduler" > /dev/null ; then
  export PATH=/usr/libexec/icecc/bin:$PATH
elif /usr/bin/pgrep --ns $$ -f "^/usr/sbin/iceccd" > /dev/null ; then
  export PATH=/usr/libexec/icecc/bin:$PATH
fi

