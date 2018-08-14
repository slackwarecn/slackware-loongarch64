#!/bin/csh
# Only add the icecream directory to the PATH if we see that icecc-scheduler
# and/or iceccd are running on this machine:

setenv ICECC_PRESENT false
/usr/bin/pgrep --ns $$ -f "^/usr/sbin/icecc-scheduler" > /dev/null
if ( $? == 0 ) then
  setenv ICECC_PRESENT true
endif

/usr/bin/pgrep --ns $$ -f "^/usr/sbin/iceccd" > /dev/null
if ( $? == 0 ) then
  setenv ICECC_PRESENT true
endif

if ( $ICECC_PRESENT == true ) then
  setenv PATH /usr/libexec/icecc/bin:${PATH}
endif

