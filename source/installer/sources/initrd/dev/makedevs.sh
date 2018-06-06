#!/bin/sh
# This script makes /dev entries for hard drives listed in /proc/partitions.
# Written by Patrick Volkerding, licensed under the GPL (any version).
# Copyright 2001, 2002  Slackware Linux, Inc., Concord, CA

# Many thanks to Vincent Rivellino for contributing the patches to support
# Mylex and Compaq RAID controllers.

# Devfs enabled kernels don't use the old familiar device names in
# /proc/partitions, so we need to be able to figure them out on the
# basis of only the major/minor numbers.  This will require some
# maintainance for a while, but we expect to require devfs soon enough,
# and that will help generalize the installation to new types of
# devices without requiring fixes from us.

# Also, we're not yet ready to install with devfs _mounted_, so don't
# try that. :)

# Main loop:
# First, determine if we are using old or new device names.  The old format
# will never contain a '/'  (Well, some RAID controllers could have them,
# but luckily we can handle those in the same way)

# Make a device:
makedev() {
  if [ ! -b $1 ]; then
    mknod $1 b $2 $3
    chown root.disk $1
    chmod 640 $1
  fi  
}

# Make ide device
# makeide major minor hd1 hd2 (2 base devs for major)
make_ide() {
  # Handle base devices:
  if [ "$2" = "0" ]; then
    makedev /dev/$3 $1 $2
    return 0
  elif [ "$2" = "64" ]; then
    makedev /dev/$4 $1 $2
    return 0
  fi
  # Must be a partition:
  if [ "`expr $2 / 64`" = "0" ]; then
    DEV=$3
    NUM=$2
  else
    DEV=$4
    NUM=`expr $2 - 64`
  fi
  makedev /dev/$DEV$NUM $1 $2
}

# Make SCSI device
make_scsi() {
  # find drive # 0 - 15
  DRV=`expr $1 / 16`
  NUM=`expr $1 % 16`
  if [ "$NUM" = "0" ]; then
    NUM=""
  fi
  if [ "$DRV" = "0" ]; then
    makedev /dev/sda$NUM 8 $1
  elif [ "$DRV" = "1" ]; then
    makedev /dev/sdb$NUM 8 $1
  elif [ "$DRV" = "2" ]; then
    makedev /dev/sdc$NUM 8 $1
  elif [ "$DRV" = "3" ]; then
    makedev /dev/sdd$NUM 8 $1
  elif [ "$DRV" = "4" ]; then
    makedev /dev/sde$NUM 8 $1
  elif [ "$DRV" = "5" ]; then
    makedev /dev/sdf$NUM 8 $1
  elif [ "$DRV" = "6" ]; then
    makedev /dev/sdg$NUM 8 $1
  elif [ "$DRV" = "7" ]; then
    makedev /dev/sdh$NUM 8 $1
  elif [ "$DRV" = "8" ]; then
    makedev /dev/sdi$NUM 8 $1
  elif [ "$DRV" = "9" ]; then
    makedev /dev/sdj$NUM 8 $1
  elif [ "$DRV" = "10" ]; then
    makedev /dev/sdk$NUM 8 $1
  elif [ "$DRV" = "11" ]; then
    makedev /dev/sdl$NUM 8 $1
  elif [ "$DRV" = "12" ]; then
    makedev /dev/sdm$NUM 8 $1
  elif [ "$DRV" = "13" ]; then
    makedev /dev/sdn$NUM 8 $1
  elif [ "$DRV" = "14" ]; then
    makedev /dev/sdo$NUM 8 $1
  elif [ "$DRV" = "15" ]; then
    makedev /dev/sdp$NUM 8 $1
  fi
}

# Make Mylex RAID device
make_rd() {
  if [ ! -d /dev/rd ]; then
    mkdir /dev/rd
  fi
  # find drive
  DRV=`expr $3 / 8`
  NUM="p`expr $3 % 8`"
  if [ "$NUM" = "p0" ]; then
    NUM=""
  fi
  makedev /dev/rd/c$1d$DRV$NUM $2 $3
}

# Make Cpq SMART/2 RAID device
make_ida() {
  if [ ! -d /dev/ida ]; then
    mkdir /dev/ida
  fi
  # find drive
  DRV=`expr $3 / 16`
  NUM="p`expr $3 % 16`"
  if [ "$NUM" = "p0" ]; then
    NUM=""
  fi
  makedev /dev/ida/c$1d$DRV$NUM $2 $3
}

# Make Compaq Next Generation RAID device
make_cciss() {
  if [ ! -d /dev/cciss ]; then
    mkdir /dev/cciss
  fi
  # find drive
  DRV=`expr $3 / 16`
  NUM="p`expr $3 % 16`"
  if [ "$NUM" = "p0" ]; then
    NUM=""
  fi
  makedev /dev/cciss/c$1d$DRV$NUM $2 $3
}

# Make ATA RAID device
make_ataraid() {
  if [ ! -d /dev/ataraid ]; then
     mkdir /dev/ataraid
  fi
  # find drive
  DRV=`expr $2 / 16`
  NUM=`expr $2 % 16`
  if [ "$NUM" = "0" ]; then
     makedev /dev/ataraid/d$DRV $1 $2
  else
     makedev /dev/ataraid/d${DRV}p$NUM $1 $2
  fi
}


# Make AMI HyperRAID device:
make_amiraid() {
  if [ ! -d /dev/amiraid ]; then
     mkdir /dev/amiraid
  fi
  # find drive
  DRV=`expr $2 / 16`
  NUM=`expr $2 % 16`
  if [ "$NUM" = "0" ]; then
     makedev /dev/amiraid/ar$DRV $1 $2
  else
     makedev /dev/amiraid/ar${DRV}p$NUM $1 $2
  fi
}

if cat /proc/partitions | grep / 1> /dev/null 2> /dev/null ; then # new
  cat /proc/partitions | grep / | while read line ; do
    SMASHED_LINE=$line
    MAJOR=`echo $SMASHED_LINE | cut -f 1 -d ' '`
    MINOR=`echo $SMASHED_LINE | cut -f 2 -d ' '`
    if [ "$MAJOR" = "3" ]; then
      make_ide $MAJOR $MINOR hda hdb
    elif [ "$MAJOR" = "8" ]; then
      make_scsi $MINOR
    elif [ "$MAJOR" = "22" ]; then
      make_ide $MAJOR $MINOR hdc hdd
    elif [ "$MAJOR" = "33" ]; then
      make_ide $MAJOR $MINOR hde hdf
    elif [ "$MAJOR" = "34" ]; then
      make_ide $MAJOR $MINOR hdg hdh
    elif [ "$MAJOR" = "48" ]; then
      make_rd 0 $MAJOR $MINOR
    elif [ "$MAJOR" = "49" ]; then
      make_rd 1 $MAJOR $MINOR
    elif [ "$MAJOR" = "50" ]; then
      make_rd 2 $MAJOR $MINOR
    elif [ "$MAJOR" = "51" ]; then
      make_rd 3 $MAJOR $MINOR
    elif [ "$MAJOR" = "52" ]; then
      make_rd 4 $MAJOR $MINOR
    elif [ "$MAJOR" = "53" ]; then
      make_rd 5 $MAJOR $MINOR
    elif [ "$MAJOR" = "54" ]; then
      make_rd 6 $MAJOR $MINOR
    elif [ "$MAJOR" = "55" ]; then
      make_rd 7 $MAJOR $MINOR
    elif [ "$MAJOR" = "56" ]; then
      make_ide $MAJOR $MINOR hdi hdj
    elif [ "$MAJOR" = "57" ]; then
      make_ide $MAJOR $MINOR hdk hdl
    elif [ "$MAJOR" = "72" ]; then
      make_ida 0 $MAJOR $MINOR
    elif [ "$MAJOR" = "73" ]; then
      make_ida 1 $MAJOR $MINOR
    elif [ "$MAJOR" = "74" ]; then
      make_ida 2 $MAJOR $MINOR
    elif [ "$MAJOR" = "75" ]; then
      make_ida 3 $MAJOR $MINOR
    elif [ "$MAJOR" = "76" ]; then
      make_ida 4 $MAJOR $MINOR
    elif [ "$MAJOR" = "77" ]; then
      make_ida 5 $MAJOR $MINOR
    elif [ "$MAJOR" = "78" ]; then
      make_ida 6 $MAJOR $MINOR
    elif [ "$MAJOR" = "79" ]; then
      make_ida 7 $MAJOR $MINOR
    elif [ "$MAJOR" = "88" ]; then
      make_ide $MAJOR $MINOR hdm hdn
    elif [ "$MAJOR" = "89" ]; then
      make_ide $MAJOR $MINOR hdo hdp
    elif [ "$MAJOR" = "90" ]; then
      make_ide $MAJOR $MINOR hdq hdr
    elif [ "$MAJOR" = "91" ]; then
      make_ide $MAJOR $MINOR hds hdt
    elif [ "$MAJOR" = "101" ]; then
      make_amiraid $MAJOR $MINOR
    elif [ "$MAJOR" = "104" ]; then
      make_cciss 0 $MAJOR $MINOR
    elif [ "$MAJOR" = "105" ]; then
      make_cciss 1 $MAJOR $MINOR
    elif [ "$MAJOR" = "106" ]; then
      make_cciss 2 $MAJOR $MINOR
    elif [ "$MAJOR" = "107" ]; then
      make_cciss 3 $MAJOR $MINOR
    elif [ "$MAJOR" = "108" ]; then
      make_cciss 4 $MAJOR $MINOR
    elif [ "$MAJOR" = "109" ]; then
      make_cciss 5 $MAJOR $MINOR
    elif [ "$MAJOR" = "110" ]; then
      make_cciss 6 $MAJOR $MINOR
    elif [ "$MAJOR" = "111" ]; then
      make_cciss 7 $MAJOR $MINOR
    elif [ "$MAJOR" = "114" ]; then
      make_ataraid $MAJOR $MINOR
    fi
  done
else # old format
  cat /proc/partitions | grep d | while read line ; do
    SMASHED_LINE=$line
    MAJOR=`echo $SMASHED_LINE | cut -f 1 -d ' '`
    MINOR=`echo $SMASHED_LINE | cut -f 2 -d ' '`
    DEVNAME=`echo $SMASHED_LINE | cut -f 4 -d ' '`
    makedev /dev/$DEVNAME $MAJOR $MINOR
  done
fi
