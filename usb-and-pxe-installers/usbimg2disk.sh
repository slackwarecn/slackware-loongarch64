#!/bin/sh
# $Id: usbimg2disk.sh,v 1.2 2009/05/14 10:29:38 eha Exp eha $
#
# Copyright 2009  Eric Hameleers, Eindhoven, NL
# All rights reserved.
#
# Redistribution and use of this script, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this script must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
#  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
#  EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
#  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
#  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Paranoid as usual:
set -e

showhelp() {
  echo "# "
  echo "# Purpose: to use the content of Slackware's usbboot.img and transform"
  echo "#   a standard USB thumb drive with a single vfat partition"
  echo "#   into an alternative USB boot device for the Slackware installer."
  echo "# "
  echo "# Reason: some computers refuse to boot from a USB thumb drive if it was"
  echo "#   made bootable by dumping 'usbboot.img' onto it."
  echo "# "
  echo "# Your USB thumb drive may contain data!"
  echo "# This data will *not* be overwritten, unless you have"
  echo "#   explicitly chosen to format the drive by using the '-f' parameter."
  echo "# "
  echo "# $(basename $0) accepts the following parameters:"
  echo "#   -h|--help                  This help"
  echo "#   -f|--format                Format the USB drive before use"
  echo "#   -i|--infile <filename>     Full path to the usbboot.img file"
  echo "#   -l|--logfile <filename>    Optional logfile to catch fdisk output"
  echo "#   -o|--outdev <filename>     The device name of your USB drive"
  echo "#   -u|--unattended            Do not ask any questions"
  echo "# "
  echo "# Example:"
  echo "# "
  echo "# $(basename $0) -i ~/download/usbboot.img -o /dev/sdX"
  echo "# "
}

reformat() {
  # Commands to re-create a functional USB stick with VFAT partition:
  # Only parameter: the name of the USB device to be formatted:
  TOWIPE="$1"

  # Sanity checks:
  if [ ! -b $TOWIPE ]; then
    echo "*** Not a block device: '$TOWIPE' !"
    exit 1
  fi

  # Wipe the MBR:
  dd if=/dev/zero of=$TOWIPE bs=512 count=1

  # create a FAT32 partition (type 'b')
  /sbin/fdisk $TOWIPE <<EOF
n
p
1


t
b
w
EOF

  # Format with a vfat filesystem:
  /sbin/mkdosfs -F32 ${TOWIPE}1
}

makebootable() {
  # Only parameter: the name of the USB device to be set bootable:
  USBDRV="$1"

  # Sanity checks:
  if [ ! -b $USBDRV ]; then
    echo "Not a block device: '$USBDRV' !"
    exit 1
  fi

  # Set the bootable flag for the first (and only...) partition:
  /sbin/sfdisk $USBDRV -N1 <<EOF
,,,*
EOF
}

# Parse the commandline parameters:
if [ -z "$1" ]; then
  showhelp
  exit 1
fi
while [ ! -z "$1" ]; do
  case $1 in
    -f|--format)
      REFORMAT=1
      shift
      ;;
    -h|--help)
      showhelp
      exit
      ;;
    -i|--infile)
      USBIMG="$(cd $(dirname $2); pwd)/$(basename $2)"
      shift 2
      ;;
    -l|--logfile)
      LOGFILE="$(cd $(dirname $2); pwd)/$(basename $2)"
      shift 2
      ;;
    -o|--outdev)
      TARGET="$2"
      TARGETPART="${TARGET}1"
      shift 2
      ;;
    -u|--unattended)
      UNATTENDED=1
      shift
      ;;
    *)
      echo "Unknown parameter '$1'!"
      exit 1
      ;;
  esac
done

# Before we start:
[ -x /bin/id ] && CMD_ID="/bin/id" || CMD_ID="/usr/bin/id"
if [ "$($CMD_ID -u)" != "0" ]; then
  echo "You need to be root to run $(basename $0)."
  exit 1
fi

# Prepare the environment:
UNATTENDED=${UNATTENDED:-0}   # unattended means: never ask questions.
REFORMAT=${REFORMAT:-0}       # do not try to reformat by default
LOGFILE=${LOGFILE:-/dev/null} # silence by default

# Sanity checks:
if [ -z "$TARGET" -o -z "$USBIMG" ]; then
  echo "*** You must specify both the names of usbboot.img and the USB device!"
  exit 1
fi

if [ ! -f $USBIMG ]; then
  echo "*** This is not a useable file: '$USBIMG' !"
  exit 1
fi

if [ $REFORMAT -eq 0 ]; then
  if ! /sbin/blkid -t TYPE=vfat $TARGETPART 1>/dev/null 2>/dev/null ; then
    echo "*** I fail to find a 'vfat' partition: '$TARGETPART' !"
    echo "*** If you want to format the USB thumb drive, add the '-f' parameter."
    exit 1
  fi
else
  if [ ! -b $TARGET ]; then
    echo "*** Not a block device: '$TARGET' !"
    exit 1
  fi
fi

if mount | grep -q $TARGETPART ; then
  echo "***"
  echo "*** Please un-mount $TARGETPART first, then re-run this script!"
  echo "***"
  exit 1
fi

# Check for prerequisites:
if [ ! -r /usr/lib/syslinux/mbr.bin -o ! -x /usr/bin/syslinux ]; then
  echo "This script requires that the syslinux package is installed!"
  exit 1
fi

# Show the USB device's information to the user:
if [ $UNATTENDED -eq 0 ]; then
  [ $REFORMAT -eq 1 ] && DOFRMT="format and " || DOFRMT="" 

  echo ""
  echo "# We are going to ${DOFRMT}use this device - '$TARGET'."
  /sbin/fdisk -l $TARGET | while read LINE ; do echo "# $LINE" ; done
  echo ""

  echo "***                                                       ***"
  echo "*** If this is the wrong drive, then press CONTROL-C now! ***"
  echo "***                                                       ***"

  read -p "Or press ENTER to continue: " JUNK
  # OK... the user was sure about the drive...
fi

# Initialize the logfile:
cat /dev/null > $LOGFILE

# If we need to format the USB drive, do it now:
if [ $REFORMAT -eq 1 ]; then
  echo "--- Formatting $TARGET and creating VFAT partition..."
  if [ $UNATTENDED -eq 0 ]; then
    echo "--- Last chance! Press CTRL-C to abort!"
    read -p "Or press ENTER to continue: " JUNK
  fi
  ( reformat $TARGET ) 1>>$LOGFILE 2>&1
fi

# Create a temporary mount point for the image file:
mkdir -p /mnt
MNTDIR1=$(mktemp -d -p /mnt -t img.XXXXXX)
if [ ! -d $MNTDIR1 ]; then
  echo "*** Failed to create a temporary mount point for the image!"
  exit 1
else
  chmod 700 $MNTDIR1
fi

# Create a temporary mount point for the USB thumb drive partition:
MNTDIR2=$(mktemp -d -p /mnt -t usb.XXXXXX)
if [ ! -d $MNTDIR2 ]; then
  echo "*** Failed to create a temporary mount point for the usb thumb drive!"
  exit 1
else
  chmod 700 $MNTDIR2
fi

# Mount the image file:
mount -o loop $USBIMG $MNTDIR1

# Mount the vfat partition
mount $TARGETPART $MNTDIR2

# Check available space:
USBFREE=$(df -k $TARGETPART | grep "^$TARGETPART" |tr -s ' ' | cut -d' ' -f4)
IMGSIZE=$(du -k $USBIMG | cut -f1)
echo "--- Available free space on the the USB drive is $USBFREE KB"
echo "--- Required free space: $IMGSIZE KB"

# Exit when the image size appears larger than available space:
if [ $IMGSIZE -gt $USBFREE ]; then
  echo "*** The USB thumb drive does not have enough free space!"
  # Cleanup and exit:
  umount -f $MNTDIR1
  umount -f $MNTDIR2
  rmdir $MNTDIR1 $MNTDIR2
  exit 1
fi

# Copy files to the USB disk in it's own subdirectory '/syslinux'
echo "--- Copying files to the USB drive..."
mkdir -p $MNTDIR2/syslinux
cp -a $MNTDIR1/* $MNTDIR2/syslinux/
rm -f $MNTDIR2/syslinux/ldlinux.sys

# Unmount everything:
umount -f $MNTDIR1
umount -f $MNTDIR2

# Remove the temporary directories:
rmdir $MNTDIR1 $MNTDIR2

# Run syslinux and write a good MBR:
echo "--- Making the USB drive '$TARGET' bootable..."
( makebootable $TARGET ) 1>>$LOGFILE 2>&1
/usr/bin/syslinux -s -d /syslinux $TARGETPART 1>>$LOGFILE 2>&1
dd if=/usr/lib/syslinux/mbr.bin of=$TARGET 1>>$LOGFILE 2>&1

# THE END
