Slackware RAID HOWTO

Version 1.02
2013/03/09

by Amritpal Bath <amrit@slackware.com>



Contents
===============================================================================

- Changelog
- Introduction
- Warnings
- Planning
- Setup
- Using the generic kernel
- Troubleshooting
- Appendices
- Acknowledgements/References




Changelog
===============================================================================

1.02 (2013/05/16):
  - Various fixups
1.01 (2011/03/15):
  - Added Robby Workman's --metadata edits per James Davies' tip.
1.00 (2008/04/09):
  - Intitial release.




Introduction
===============================================================================

This document explains how to install Slackware 13.0 (and beyond) on a
software RAID root filesystem.  It is meant to cover only software raid.
If you are using a RAID expansion card, or the RAID functionality that came
with your motherboard, this document will not be useful for you.

In order to follow this document, your computer must have two or more empty
hard drives.  While it is possible to be creative and create RAID arrays on
drives that already contain data, it can be error prone, so it is not
covered in this document.




Warnings
===============================================================================

If you perform the following instructions on hard drives with data on them,
YOU WILL LOSE ALL OF YOUR DATA.

If you wish to perform these operations on hard drives that hold data of
any importance, you MUST BACKUP YOUR DATA.  The procedure below will
destroy all of the data on your hard drives, so any important data will
need to be restored from your backups.



One more time: *BACKUP YOUR DATA, OR YOU WILL LOSE IT!*

If you don't backup your data and end up losing it, it will be your fault.
There is nothing I can do to help you in that case.

Now, on with the show... :)




Planning
===============================================================================

The first step is to determine which RAID level you want to use.

It is recommended that you familiarize yourself with basic RAID concepts,
such as the various RAID levels that are available to you.  You can read
about these in various places - consult your favorite search engine about
"raid levels", or see the References section.

Here's a quick summary of the more common RAID levels:

 - RAID 0: Requires 2 drives, can use more.  Offers no redundancy, but
   improves performance by "striping", or interleaving, data between all
   drives.  This RAID level does not help protect your data at all.
   If you lose one drive, all of your data will be lost.

 - RAID 1: Requires 2 drives, can use more.  Offers data redundancy by
   mirroring data across all drives.  This RAID level is the simplest way
   to protect your data, but is not the most space-efficient method.  For
   example, if you use 3 drives in a RAID 1 array, you gain redundancy, but
   you still have only 1 disk's worth of space available for use.

 - RAID 5: Requires 3 drives, can use more.  Offers data redundancy by
   storing parity data on each drive.  Exactly one disk's worth of space
   will be used to hold parity data, so while this RAID level is heaviest
   on the CPU, it is also the most space efficient way of protecting your
   data.  For example, if you use 5 drives to create a RAID 5 array, you
   will only lose 1 disk's worth of space (unlike RAID 1), so you will
   end up with 4 disk's worth of space available for use.  While simple to
   setup, this level is not quite as straightforward as setting up RAID 1.




Setup
===============================================================================

=== Partition hard drives ===

Once you have booted the Slackware installer CD, the first step is to
partition the hard drives that will be used in the RAID array(s).

I will assume that your first RAID hard drive is /dev/sda.  If it is
/dev/hda or something similar, adjust the following commands appropriately.

You can see your drives by running: cat /proc/partitions

 - /boot: RAID 0 and RAID 5 users will require a separate boot partition, as
   the computer's BIOS will not understand striped devices.  For
   simplicity's sake, we will make /boot a small RAID 1 (mirror) array.
   This means that in the case of RAID 0, it will not matter which drive
   your BIOS attempts to boot, and in the case of RAID 5, losing one drive
   will not result in losing your /boot partition.

   I recommend at least 50MB for this partition, to give yourself room to
   play with multiple kernels in the future, should the need arise.  I tend
   to use 100MB, so I can put all sorts of bootable images on the partition,
   such as MemTest86, for example.

   Go ahead and create a small boot partition now on /dev/sda, via cfdisk
   (or fdisk, if you prefer).

   Ensure that the partition type is Linux RAID Autodetect (type FD).


 - /: Every setup will require a root partition. :)  You will likely want to
   create a partition takes up most of the rest of the drive.  Unless you
   are using LVM (not covered in this document), remember to save some space
   after this partition for your swap partition! (see below)

   If you are not creating a swap partition, I recommend leaving 100MB of
   unused space at the end of the drive.  (see "safety" for explanation)

   Go ahead and create your main partition now on /dev/sda, via cfdisk
   (or fdisk, if you prefer).

   Ensure that the partition type is Linux RAID Autodetect (type FD).


 - swap: Swap space is where Linux stores data when you're running low on
   available RAM.  For fairly obvious reasons, building this on RAID 0 could
   be painful (if that array develops a bad sector, for example), so I tend
   to build swap on RAID 1 as well.  If you understand the danger and still
   want to build swap on RAID 0 to eke out as much performance as possible,
   go for it.

   For RAID 1 swap, create a partition that is the exact size that you want
   your swap space to be (for example, 2GB, if you can't decide).

   For RAID 0 swap (not recommended), create a partition that is equivalent
   to the swap size you want, divided by the number of drives that will be
   in the array.

   For example, 2GB / 3 drives = 683MB swap partition on /dev/sda.

   Ensure that the partition type is Linux RAID Autodetect (type FD).

   I recommend leaving 100MB of unused space at the end of the drive.
   (see "safety" for explanation)

   See also: Appendix A - Striping swap space without RAID 0.


 - safety!  I highly recommend leaving 100MB of unpartitioned space at the
   end of each drive that will be used in the RAID array(s).

   In the event that you need to replace one of the drives in the array,
   there is no guarantee that the new drive will be exactly the same size as
   the drive that you are replacing.  For example, even if both drives are
   750GB, they may be different revisions or manufacturers, and thus have a
   size difference of some small number of megabytes.

   This is, however, enough to throw a wrench in your drive-replacement
   plans - you cannot replace a failed RAID drive with one of a smaller size,
   for obvious reasons.  Having that small 100MB buffer just may save your
   bacon.



=== Copy and review partitions ===

Now that /dev/sda is partitioned as appropriate, copy the partitions to all
the other drives to be used in your RAID arrays.

An easy way to do this is:
  sfdisk -d /dev/sda | sfdisk --Linux /dev/sdb

This will destroy all partitions on /dev/sdb, and replicate /dev/sda's
partition setup onto it.

After this, your partitions should look something like the following:

 - RAID 0:
     /dev/sda1  50MB      /dev/sdb1  50MB   
     /dev/sda2  100GB     /dev/sdb2  100GB  
     /dev/sda3  2GB       /dev/sdb3  2GB    

 - RAID 1:
     /dev/sda1  100GB     /dev/sdb1  100GB  
     /dev/sda2  2GB       /dev/sdb2  2GB    

 - RAID 5:
     /dev/sda1  50MB      /dev/sdb1  50MB     /dev/sdc1  50MB 
     /dev/sda2  100GB     /dev/sdb2  100GB    /dev/sdc2  100GB
     /dev/sda3  2GB       /dev/sdb3  2GB      /dev/sdc3  2GB  
  
All partition types should be Linux RAID Autodetect (type fd).



=== Create RAID arrays ===

Now it's time to create the actual RAID arrays based on the partitions that
were created.

The parameters for each of these RAID commands specifies, in order:
 - the RAID device node to create (--create /dev/mdX)
 - the name to use for this array (--name=X)
   Note that there is no requirement that you use this format, i.e.
   /dev/md0 --> name=0 ; the result is that /dev/md0 will be /dev/md/0,
   which means you could also do e.g. --name=root and get /dev/md/root
 - the RAID level to use for this array (--level X)
 - how many devices (partitions) to use in the array (--raid-devices X)
 - the actual list of devices (/dev/sdaX /dev/sdbX /dev/sdcX)
 - this is not present on all of them, but "--metadata=0.90" tells mdadm
   to use the older version 0.90 metadata instead of the newer version;
   you must use this for any array from which LILO will be loading a 
   kernel image, or else LILO won't be able to read from it.
 - OPTIONAL: if you know the hostname you plan to give the system, you 
   could also specify "--homehost=hostname" when creating the arrays.

Start by creating the RAID array for your root filesystem.

 - RAID 0:
     mdadm --create /dev/md0 --name=0 --level 0 --raid-devices 2 \
       /dev/sda2 /dev/sdb2

 - RAID 1:
     mdadm --create /dev/md0 --level 1 --raid-devices 2 \
       /dev/sda1 /dev/sdb1 --metadata=0.90

 - RAID 5:
     mdadm --create /dev/md0 --name=0 --level 5 --raid-devices 3 \
       /dev/sda2 /dev/sdb2 /dev/sdc2


Next, let's create the array for the swap partition.  This will be RAID 1
regardless of which RAID level your root filesystem uses, but given our
partition layouts, each command will still be slightly different.

 - RAID 0:
     mdadm --create /dev/md1 --name=1 --level 1 --raid-devices 2 \
       /dev/sda3 /dev/sdb3

 - RAID 1:
     mdadm --create /dev/md1 --name=1 --level 1 --raid-devices 2 \
       /dev/sda2 /dev/sdb2

 - RAID 5:
     mdadm --create /dev/md1 --name=1 --level 1 --raid-devices 3 \
       /dev/sda3 /dev/sdb3 /dev/sdc3


Finally, RAID 0 and RAID 5 users will need to create their /boot array.
RAID 1 users do not need to do this.

 - RAID 0:
     mdadm --create /dev/md2 --name=2 --level 1 --raid-devices 2 \
       /dev/sda1 /dev/sdb1 --metadata=0.90

 - RAID 5:
     mdadm --create /dev/md2 --name=2 --level 1 --raid-devices 3 \
       /dev/sda1 /dev/sdb1 /dev/sdc1 --metadata=0.90


We're all done creating our arrays!  Yay!



=== Run Slackware setup ===

First, let's format our swap array, so the installer recognizes it:
  mkswap /dev/md1

Now run 'setup' as normal.

When you choose to setup your swap partitions, /dev/md1 will show up.
Continue with this selected.

When asked for the target partition, choose the root array (/dev/md0).

You may choose the format method and filesystem of your choice.

RAID 0 and RAID 5 users must also setup /boot.  When asked about setting up
extra partitions, choose /dev/md2.  When asked where to mount this device,
enter "/boot".

After this, continue installation as normal.

For LILO configuration:
 - When asked about LILO, choose the "simple" setup.
 - When asked about additional "append=" parameters, RAID 0 and
   RAID 5 users should type in "root=/dev/md0", to ensure that the proper
   array is mounted on / at bootup.
 - When asked about where to install LILO, choose MBR.

You may see some warnings scroll by.  This is OK.



=== Finishing touches ===

After exiting the installer, we have just a few settings to tweak.

Start by switching into your actual installation directory:
 - chroot /mnt


Let's make sure LILO boots from the RAID arrays properly.  Using your
favorite editor (vim/nano/pico), edit /etc/lilo.conf:
 - add a new line (add it anywhere, but don't indent it):
     raid-extra-boot = mbr-only
 - You will need to change the following line:
     boot = <something>
   RAID 0 and RAID 5 users, change it to:
     boot = /dev/md2
   RAID 1 users, change it to:
     boot = /dev/md0
   
 - Save the file and exit your editor.
 - run "lilo".


Now's let's create a customized /etc/mdadm.conf for your system:
 - mdadm -Es > /etc/mdadm.conf
You should get something like this (note that this output is not consistent
with the instructions above):
  ARRAY /dev/md0 UUID=bb259b84:6bf27834:208cdb8d:9e23b04b
  ARRAY /dev/md1  metadata=1.2 UUID=ea798427:4ae79ea8:9e7e263d:5ae8f69e name=slackware:1
  ARRAY /dev/md2  metadata=1.2 UUID=4ca90e7a:99de6d09:f1f9ca9d:b2ea6e1b name=slackware:2

If this is done on a live running system, you will notice that the arrays
created with 1.2 metadata will show /dev/md/$name (e.g. /dev/md/1) instead
of /dev/md1 in /etc/mdadm.conf; this is perfectly acceptable, and actually
preferable, so you might want to go ahead and fix that now.

If you plan to run the generic kernel (which is probably necessary, but you 
are certainly welcome to try the huge kernel instead), then continue on to
the next section; otherwise, skip to the exit and reboot part.



Using the generic kernel
===============================================================================

The official Slackware recommendation is to switch to the "generic"
Slackware kernel after installation has been completed.  If you wish to use
the generic kernel, you must create an initrd.  This section gives a quick
example of booting a RAID system in this fashion.

If you require more information on initrds, please read /boot/README.initrd.


Typically, a user switches to a generic kernel by booting the system, and
afterwards running the following:
 - cd /boot
 - rm vmlinuz System.map config
 - ln -s vmlinuz-generic-smp-*     vmlinuz
 - ln -s System.map-generic-smp-*  System.map
 - ln -s config-generic-smp-*      config

Don't run lilo yet, we'll do that soon.


Next, edit (create, if necessary) /etc/mkinitrd.conf and add:
  MODULE_LIST="ext4"
  RAID="1"

Obviously, this assumes that you are using the EXT4 filesystem.  If you are
using another filesystem, adjust the module appropriately (reiserfs or xfs,
for example).  If you wish to read more about the MODULE_LIST variable,
consult "man mkinitrd.conf".  Alternatively, you might find that the helper
script at /usr/share/mkinitrd/mkinitrd_command_generator.sh works well for
you by doing this:
  /usr/share/mkinitrd/mkinitrd_command_generator.sh > /etc/mkinitrd.conf


Note: If the module for your hard drive controller is not compiled into the
generic kernel, you will want to add that module to the MODULE_LIST variable
in mkinitrd.conf.  For example, my controller requires the mptspi module, so
my /etc/mkinitrd.conf looks like:
  MODULE_LIST="ext4:mptspi"
  RAID="1"


We're almost done.

Edit /etc/lilo.conf, and find the line at the very end that says:
  image = /boot/vmlinuz
Add a new line after it that says:
  initrd = /boot/initrd.gz
In this case, be sure to indent the line you've added!


Next, create the initrd based on the config file created earlier.
  mkinitrd -F


Finally, run "lilo" to make the new settings take effect, give yourself a
pat on the back, and reboot your finished system. :)


When that's done, let's exit the installation and reboot:
  - exit
  - reboot

Voila!



Troubleshooting
===============================================================================

Any number of typos can result in a system that does not boot on its own,
but all is not lost.  Put the rubber chicken and the lemon away...

Booting your Slackware media (DVD, for example) can make it very easy to
switch into your installed system and make repairs:

 - Boot Slackware CD/DVD.
 - Login to installer as normal.
 - Scan for, and then assemble the RAID arrays:
     mdadm -Es > /etc/mdadm.conf
     mdadm -As
 - Mount root partition:
     mount /dev/md0 /mnt
 - Switch to installed OS:
     chroot /mnt
 - Mount remaining filesystems:
     mount /boot (RAID 0 and RAID 5 users only)
     mount /proc
     mount sys /sys -t sysfs

At this point, you can bring up your favorite editor, tweak config files,
re-run mkinitrd/lilo/etc as you wish, or anything else you need to do to
make your system bootable again.

When you're finished making your changes, rebooting is simple:

 - cd /
 - umount boot proc sys
 - exit
 - reboot

If you are having issues that you're unable to resolve, shoot me an email.
Perhaps the answer will make it into this section. :)




Appendices
===============================================================================

=== Appendix A: Striping swap space without RAID 0 ===

For completeness' sake, I should mention that swap space can be striped to
improve performance without creating a RAID 0 array.

To accomplish this, start by forgetting about any instructions having to do
with /dev/md1, which would be our swap array - create the swap partitions on
the hard drives, but do not create this particular array.

When creating the swap partitions, ensure that the partition type is set to
Linux Swap (type 82).

During setup, the installer will recognize the swap partitions.  Ensure that
all of them are selected, and continue as normal.


After installation is complete, go ahead and boot your system - we can
finish this once the system is booted, in the interest of simplicity.


When the system boots, edit /etc/fstab with your favorite editor.  Find the
lines that describe your swap partitions - they say "swap" in the second
column.

Each of these lines says "default" in the fourth column.  Simply change that
to "default,pri=0" for each line.

After saving the file, either reboot, or simply run:
  swapoff -a
  swapon -a

To confirm that the setting has taken effect, you can run:
  swapon -s

Verify that the Priority column reads 0 for each partition, and we're done!




Acknowledgements/References
===============================================================================

- In depth explanation of RAID levels:
  "LasCon Storage - Different types of RAID"
  http://www.lascon.co.uk/d008005.htm

- Thanks to John Jenkins (mrgoblin) for some tips in:
  "Installing with Raid on Slackware 12.0+"
  http://slackware.com/~mrgoblin/articles/raid1-slackware-12.php

- Thanks to Karl Magnus Kolstø (karlmag) for his original writeup on
  Slackware and RAID, ages ago!
  "INSTALLING SLACKWARE LINUX version 8.1 WITH ROOT PARTITION ON A SOFTWARE
   RAID level 0 DEVICE"
  http://slackware.com/~mrgoblin/articles/raid0-slackware-linux.php

- Of course, thanks to Patrick "The Man" Volkerding for creating Slackware!
  http://slackware.com/

- Also thanks to the rest of the guys that proofread, tested, and suggested!
  Eric Hameleers (alienBOB), Robby Workman, Alan Hicks,
  Piter Punk, Erik Jan Tromp (alphageek)...

- My contact info:
  Primary email:    amrit@slackware.com
  Secondary email:  amrit@transamrit.net
  On certain IRC networks: "amrit" (or some variation :) )

- This latest version of this document can be found at:
  http://slackware.com/~amrit/
  http://transamrit.net/docs/slackware/
