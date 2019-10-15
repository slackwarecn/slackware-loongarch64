#!/bin/csh
# Only add the icecream directory to the PATH if we see that iceccd is
# supposed to be running on this machine:

if ( -x /etc/rc.d/rc.iceccd ) then
  setenv PATH /usr/libexec/icecc/bin:${PATH}
endif
