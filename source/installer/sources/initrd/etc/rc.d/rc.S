#!/bin/sh
# rc.S: Basic system initialization.

# Mount /proc:
/sbin/mount -v proc /proc -t proc 1> /dev/null

# Mount sysfs next:
/sbin/mount -v sysfs /sys -t sysfs 1> /dev/null

# The efivarfs filesystem is used for reading and writing EFI variables, such
# as the boot menu entries. By default efivarfs will be mounted read-write on
# the /sys/firmware/efi/efivars directory.
if [ -d /sys/firmware/efi/efivars ]; then
  mount -o rw -t efivarfs none /sys/firmware/efi/efivars
fi

# Set a root password for the Slackware Installer if set as a Kernel cmdline:
# This is intended for network installations where otherwise the root password
# would be unset.
# Note: this does not configure the OS root password.
# Passwords should be set as follows within the Kernel cmdline:
#   instrootpw=yourpassword
if grep -qoP 'instrootpw=\K\S+' /proc/cmdline ; then
  /bin/echo "root:$( grep -oP 'instrootpw=\K\S+' /proc/cmdline )" | /bin/busybox chpasswd
fi

# Activate swap:
/sbin/swapon -a 1> /dev/null

if [ -x /sbin/ldconfig ]; then
  /sbin/ldconfig 1> /dev/null
fi

## Detect serial console from kernel command line:
#if cat /proc/cmdline | grep console=ttyS 1> /dev/null 2> /dev/null ; then
#  SERIAL_CONSOLE="true"
#fi

# System logger (mostly to eat annoying messages):
/sbin/syslogd 2> /dev/null
sleep 1
/sbin/klogd -c 3 1> /dev/null

# Try to load the loop module:
modprobe loop 1> /dev/null 2> /dev/null

# Run udev:
if ! grep -wq noudev /proc/cmdline ; then
  /bin/bash /etc/rc.d/rc.udev start

  # Re-assemble RAID volumes:
  /sbin/mdadm -E -s > /etc/mdadm.conf
  /sbin/mdadm -S -s
  /sbin/mdadm -A -s
  # This seems to make the kernel see partitions more reliably:
  fdisk -l /dev/md* 1> /dev/null 2> /dev/null
else
  # Run our old detection routines:

  # Look for USB keyboard or storage:
  /etc/rc.d/rc.usb start
  sleep 3

  # Look for IEEE1394 devices:
  if grep 1394 /proc/pci 1> /dev/null 2> /dev/null ; then
    /etc/rc.d/rc.ieee1394 start
    #sleep 3
  fi

  # Load additional install floppies:
  for NEWDISK in 2 ; do
    if [ ! -r /etc/disk${NEWDISK} ]; then
      while [ 0 ]; do
        echo
        echo -n "Insert install.${NEWDISK} floppy disk to be loaded into RAM disk and press ENTER"
        read readfoo;
        if [ "$readfoo" = "Q" -o "$readfoo" = "q" ]; then
          break;
        fi
        echo -n "Loading install.${NEWDISK} floppy into RAM disk...  "
        ( cd / ; cat /dev/fd0 | zcat 2> /dev/null | tar xf - )
        if [ -r /etc/disk${NEWDISK} ]; then
          echo "done."
          echo
          break;
        else
          echo "Error. (reload or enter Q)"
          echo
          continue;
        fi
      done
    fi
  done

  ### PROBABLY USELESS WITHOUT SOME TIMED DELAY ABOVE
  ## Start USB again (in case we missed a USB keyboard)
  #/etc/rc.d/rc.usb start

  # Make detected partitions:
  /dev/makedevs.sh

  ## Not needed with CONFIG_SCSI_MULTI_LUN=y
  #unset SCAN
  ## Now we should rescan the "SCSI" bus to look for new USB or firewire devices
  ## that look like SCSI devices:
  #if [ -r /proc/bus/usb/devices ]; then
  #  if cat /proc/bus/usb/devices | grep -w usb-storage 1> /dev/null 2> /dev/null ; then
  #    SCAN="true"
  #  fi
  #fi
  #if [ -r /proc/bus/ieee1394/devices ]; then
  #  if cat /proc/bus/ieee1394/devices | grep -w SBP2 1> /dev/null 2> /dev/null ; then
  #    SCAN="true"
  #  fi
  #fi
  #if [ "$SCAN" = "true" ]; then
  #  if ! cat /proc/cmdline | grep -q noscanluns 2> /dev/null ; then
  #    echo "Detected new USB/IEEE1394 storage devices...  scanning all LUNs."
  #    echo "(to skip, give a 'noscanluns' kernel option at boot)"  
  #    #sleep 5
  #    sh /sbin/rescan-scsi-bus -l
  #    #sleep 1
  #  fi
  #fi
  #unset SCAN

  # Re-assemble RAID volumes:
  /sbin/mdadm -E -s > /etc/mdadm.conf
  /sbin/mdadm -S -s
  /sbin/mdadm -A -s
  # This seems to make the kernel see partitions more reliably:
  fdisk -l /dev/md* 1> /dev/null 2> /dev/null

  # Check /proc/partitions again:
  /dev/makedevs.sh

  # Create LVM nodes:
  /dev/devmap_mknod.sh

fi # End Run udev:

# Set up some swap on a ZRAM device:
ZRAMSIZE=$(echo $(cat /proc/meminfo | grep ^MemTotal:) | cut -f 2 -d ' ')
ZRAMCOMPRESSION=zstd
ZRAMPRIORITY=100
if [ ! -d /sys/devices/virtual/block/zram0 ]; then
  modprobe zram
fi
# In case of a 32-bit kernel, we are limited to 4G maximum ZRAM device size.
# If the RAM size is greater than 4G, then use 4G for the ZRAMSIZE.
if [ "$(uname -m)" = "i686" ]; then
  if [ "$ZRAMSIZE" -gt "4194304" ]; then
    ZRAMSIZE=4194304
  fi
fi
ZRAM_DEVICE=$(/sbin/zramctl -f -a $ZRAMCOMPRESSION -s ${ZRAMSIZE}K)
if [ ! -z $ZRAM_DEVICE ]; then
  /sbin/mkswap $ZRAM_DEVICE
  /sbin/swapon -p $ZRAMPRIORITY $ZRAM_DEVICE
fi
unset ZRAMCOMPRESSION ZRAM_DEVICE ZRAMPRIORITY ZRAMSIZE

# Here's the situation. Because of the practice of keeping the local
# time (rather than UTC) in the system's clock, at any given time half
# of the people doing an install will be creating files that upon
# reboot will appear to have been created in the future.
#
# There are a lot of things that aren't happy when that happens. The
# one that screams the most loudly is e2fsck, and we don't want to
# anger that! Sometimes it even proceeds to check the partitions just
# to be sure the user is fully punished.
#
# But, there's a simple solution. If we set the (temporary) Linux clock
# to yesterday (-24h), then there's no way that could occur. Everything
# on the system will be in the past (but not too far in the past).
# Since files will quickly be put into use and given the correct after
# reboot, this really shouldn't have a negative impact. Plus, it affects
# only newly created files during installation -- any file shipped in a
# package will have an accurate time of creation. (for its timezone ;-)
#
# Update: We have to use 2 days ago, or chroot()+timezone offset might
# still be in the future... <sigh>
#
touch /.today
/bin/sh /sbin/fakedate

if [ -x /etc/rc.d/rc.inet1 ]; then
  /bin/sh /etc/rc.d/rc.inet1
fi

# pcmciautils is installing rc.pcmcia as chmod 644, so we'll change that.
# It won't be run at boot time, but it'll make it easy for the pcmcia script
# or to run it from the command line.
chmod 755 /etc/rc.d/rc.pcmcia

# Scan for existing LVM partitions:
# We will run 'vgscan -ay' in the setup to prevent a 10 second sleep;
vgscan --mknodes 2> /tmp/foo
cat /tmp/foo | uniq
rm -f /tmp/foo

# Activate LVM volumes:
echo "Activating LVM volumes:"
vgchange -ay

# In testing here the results of running rc.font with HiDPI screens has been
# rather unpredicable, sometimes resulting in an unreadably small font rather
# than increasing the size. Let's skip it unless RCFONT is passed as a kernel
# command-line flag:
if cat /proc/cmdline | grep -wq RCFONT ; then
  if [ -x /etc/rc.d/rc.font ]; then
    /bin/sh /etc/rc.d/rc.font
  fi
fi

# Don't automatically blank the screen, or it will go black during the install
# process when stray keystrokes might be dangerous:
/bin/setterm -blank 0

echo > /etc/motd
echo "`/bin/uname -a | /bin/cut -d\  -f1,3`." >> /etc/motd
echo >> /etc/motd
cat << EOF >> /etc/motd
If you're upgrading an existing Slackware system, you might want to
remove old packages before you run 'setup' to install the new ones. If
you don't, your system will still work but there might be some old files
left laying around on your drive.

Just mount your Linux partitions under /mnt and type 'pkgtool'. If you
don't know how to mount your partitions, type 'pkgtool' and it will tell
you how it's done.

To partition your hard drive(s), use 'cfdisk' or 'fdisk'.
To start the main installation (after partitioning), type 'setup'.

EOF

# Dropbear seems to handle the $PATH correctly now...
#echo > /etc/motd.net
#echo "First command to run is 'source /etc/profile'." >> /etc/motd.net
#echo "This will setup the PATH for you." >> /etc/motd.net
#echo >> /etc/motd.net

# If possible, figure out what kernel we just booted with:
unset SLACK_KERNEL
for ARG in `cat /proc/cmdline` ; do
  if [ "`echo $ARG | cut -f 1 -d =`" = "SLACK_KERNEL" ]; then
    IMAGE="`echo $ARG | cut -f 2 -d =`"
    SLACK_KERNEL=$IMAGE
  fi 
done
export SLACK_KERNEL

. /etc/profile

clear
if ! cat /proc/cmdline | grep -q 'kbd=' 2> /dev/null ; then
  echo
  echo
  echo "<OPTION TO LOAD SUPPORT FOR NON-US KEYBOARD>"
  echo
  echo "If you are not using a US keyboard, you may now load a different"
  echo "keyboard map. To select a different keyboard map, please enter 1"
  echo "now. To continue using the US map, just hit enter."
  echo
  echo -n "Enter 1 to select a keyboard map: "
  read ONE
  if [ "$ONE" = "1" ]; then
    /usr/lib/setup/SeTkeymap
  fi
else
  for ARG in `cat /proc/cmdline` ; do
    if [ "`echo $ARG | cut -f1 -d=`" = "kbd" ]; then
      # A keymap was specified on the kernel command line such as: kbd=azerty
      MAPSELECT="$(echo $ARG | cut -f2 -d=)"
      # If it ends in .gz, strip that off:
      if [ "$(echo $MAPSELECT | rev | cut -f 1 -d . | rev)" = "gz" ]; then
        MAPSELECT=$(basename $MAPSELECT .gz)
      fi
      # If it doesn't end in .map, add that:
      if [ ! "$(echo $MAPSELECT | rev | cut -f 1 -d . | rev)" = "map" ]; then
        MAPSELECT=${MAPSELECT}.map
      fi
      # Load the keymap:
      loadkeys -q $MAPSELECT
      # Let the setup script know about this:
      echo $MAPSELECT > /tmp/Pkeymap
      unset MAPSELECT
    fi 
  done
fi
clear

# Provision for unattended network configuration:
/usr/lib/setup/SeTnet boot
# Start dropbear ssh server (only if a configured interface is present):
/etc/rc.d/rc.dropbear start

# Fake login:  (fooled ya! ;^)

cat /etc/issue
echo -n "slackware login: "
read BOGUS_LOGIN
cat /etc/motd
