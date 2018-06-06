#!/bin/sh
TMP=/var/log/setup/tmp
T_PX="`cat $TMP/SeTT_PX`"
#
# Like, the space is *really* getting tight on these install disks!
# Can you believe it? Anyway, we can avoid many problems by migrating
# the $TMP directory onto the install partition ASAP. So, this script
# is run right after the TARGET partition is configured and mounted
# under ${T_PX}.
#

TMPLINK="`LC_ALL=C /bin/ls -l /var/log/setup/tmp | tr -s ' ' | cut -f 11 -d ' '`"
if [ -L /var/log/setup/tmp -a "$TMPLINK" = "/tmp" ]; then
  if mount | grep " on ${T_PX} " 1> /dev/null 2> /dev/null ; then # ${T_PX} mounted
    TYPE="`mount | grep " on ${T_PX} " | cut -f 5 -d ' '`"
    if [ "$TYPE" = "umsdos" ]; then
      LINKDIR=${T_PX}/linux/var/log/setup/tmp
    else
      LINKDIR=${T_PX}/var/log/setup/tmp
    fi
    if [ ! -d $LINKDIR ]; then
      mkdir -p $LINKDIR
      chmod 700 $LINKDIR
    fi
    ( cd /var/log/setup
      rm tmp
      ln -sf $LINKDIR tmp )
    rm -f $LINKDIR/SeT*
    mv /tmp/SeT* $LINKDIR
  fi
fi
