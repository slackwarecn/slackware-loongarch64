
Installing Slackware using a bootable USB stick
===============================================

**WARNING:**
  The procedure outlined below will destroy all data that is currently
  stored on the USB stick you use to create a USB Slackware installer.


Introduction
------------

    With the release of Slackware 12.0, the era of floppy-boot came to
a definite end.  The reason is simple - the Linux 2.6 kernel will not
fit on a single floppy, even in it's most condensed configuration.
In this README, I will show you how to use a bootable USB stick to
install Slackware.  This method - creating the USB equivalent of a
boot/root floppy pair - is easy to use and fast. It requires that your
computer is able to boot from USB-HDD.


Booting the Slackware installer from a USB stick
------------------------------------------------

    The 'usbboot.img' file is a 25 MB small USB boot image that you can
use to boot into the Slackware setup program.  The mini image does not
contain any installable Slackware package.  In order to install Slackware
you will need a local NFS/HTTP/FTP server or another Slackware package
source like a prepared local harddisk partition.  This small image file
works great, especially when you can't or don't want to use CDROM media
as the carrier for the Slackware packages.
The image is transfered to a USB stick in a matter of seconds.  Even the
oldest and tiniest of USB drives is well suited for this purpose.

    The usual way of installing Slackware from a network server repository,
is to boot the Slackware CDROM, and run the ('pcmcia' and) 'network' script
that load the drivers for your network card.  You need a working network
card before running setup and go through the installation procedure.
When you type 'pcmcia' and/or 'network', the Slackware installer would look
for the appropriate driver files on an available CDROM, and if no CDROM
is found it prompts you to insert floppy disks.

    Now, with a boot from our USB stick we are assuming there is no CDROM 
and no floppy drive available to us.  So, this USB boot image contains
all the drivers you need and will not prompt you for additional 'floppies'.
A consequence of adding all the network and pcmcia drivers to the USB image
is that using a bootable USB stick is not a suitable method to install
Slackware on old PCs that are low on memory!  The ramdisk will be more than
30 MB in size, and you will need RAM for your kernel as well.


Transfering the usbboot.img file to a USB device
------------------------------------------------

In order to create a bootable USB stick with the Slackware installer on it,
copy the 'usbboot.img' file to a USB stick as follows:

(1) In a Linux terminal if you're in X, or just from the console, change
    directory to where the file 'usbboot.img' is located - you may have to
    mount your Slackware CDROM or DVD first.
(2) Insert a USB stick that is going to become your Slackware installer.
    Note that all data the stick contains will be erased in the next steps!
    You need to find out the device name for this USB stick.  Sometimes it
    helps to run the command 'rescan-scsi-bus' if the USB stick is not 
    being detected right away.
    On systems without SCSI or SATA disks, the USB stick will usually be
    assigned '/dev/sda' as the device name.  If '/dev/sda' already is your
    SCSI or SATA hard drive, then '/dev/sdb' would become the device name
    for the USB stick.  Be very convinced that you know which device name
    represents your stick before you advance to the next step!
(3) Transfer the image file to the USB stick using the 'dd' program.  In the
    example command line below, I am assuming that the USB stick is known as
    '/dev/sdx'.

      dd if=usbboot.img of=/dev/sdx bs=512

    Be careful about the device name for your USB stick!  The above 'dd' 
    command will wipe out any existing data on the device, so you had better 
    be sure that it is not the SATA hard disk you're targeting!


Booting from the USB stick
--------------------------

    Your computer BIOS must support booting from USB HDD.

    Plug the stick into your computers USB slot, and boot it up.  Make 
sure you select boot from USB-HDD - how you do this is very dependent on 
the type of computer you have.  Many computers will display a message 
during the initial stages of the booting that says something like
"Press [F12] for a boot device list".

    The Slackware installer will start just like when you had booted from 
a CDROM (maybe somewhat faster even).  Log in as root.  Start the install
by partitioning your hard drive as usual, and running 'setup'.  If you want
to install from a network server such as a NFS, HTTP or FTP server, you
should run the commands 'pcmcia' (if your network card is a PCMCIA type)
and/or 'network' prior to running 'setup' in order to load a driver for
your network card.  If you want to install Slackware using a local hard
disk partition in case you copied the content of the Slackware CDROMs/DVD
there already, that is also an option.
It would not make much sense to opt for the third install method to
"use a CDROM" since we just abandoned the use of a CDROM medium :-)


A remark about fdisk warnings
-----------------------------

    After writing the 'usbboot.img' to the USB stick, if you run fdisk -l 
you will see alarming output like this:

 This doesn't look like a partition table
 Probably you selected the wrong device.
 
    Device Boot      Start         End      Blocks   Id  System
 /dev/sda1   ?     8563200     8326647  2088818490    1  FAT12
 Partition 1 has different physical/logical beginnings (non-Linux?):
      phys=(124, 38, 11) logical=(8563199, 1, 16)
 Partition 1 has different physical/logical endings:
      phys=(344, 195, 26) logical=(8326646, 0, 49)
 Partition 1 does not end on cylinder boundary.

... and so on, for partitions 2, 3 and 4 as well.

    This is actually harmless.  The 'usbboot.img' file was copied to the
raw device, it did not create partitions at all.  Fdisk reads the information
in the first sector and incorrectly interprets that as a messed-up device.


Create a bootable USB stick non-destructively
---------------------------------------------

    If you do not want to sacrifice a USB thumb drive for this (note that
dumping the image file on the USB stick will destroy all data already
present on the stick), there is a solution: Slackware also ships with a
script usbimg2disk.sh since the 13.0 release (actually, it is the file
/usb-and-pxe-installers/usbimg2disk.sh ).  This script extracts the content
from the 'usbboot.img' image file and uses this to transform a regular USB
thumb drive into a bootable Slackware installer non-destructively (i.e. any
existing files on the stick will not be touched).  The only requirement is,
that there is at least 30 MB of available free space on the stick.

    The usbimg2disk.sh script is also convenient if your computer refuses to
boot from a USB stick loaded with the usbboot.img file. The BIOS of some
computers will not understand the format of the default Slackware USB
image. Using the usbimg2disk.sh script, you create an alternative bootable
USB stick that will be recognized by your computers BIOS.


Restoring a USB stick to its original state (empty VFAT partition)
------------------------------------------------------------------

    When you have used the small 25 MB image to create a USB installer, 
your USB stick is no longer useful for anything else.  Any remaining 
space on the stick (assuming you used a larger-than 25 MB stick for it) 
is inaccessible.  Fortunately, it is easy to re-create a FAT partition on 
the stick (thereby removing the Slackware installer of course) so that 
the USB stick again becomes available for carrying around your data.

    Take care about which device actually is your USB stick !!! The next 
command will render all data on /dev/sdx inaccessible !!!

(1) First, wipe the bootsector of the USB stick:

      dd if=/dev/zero of=/dev/sdx bs=512 count=1

(2) Then, create a new FAT32 partition on the stick and write a FAT32 
    filesystem on it (vfat or type b in fdisk terminology):

fdisk /dev/sdx <<EOF
n
p
1


t
b
w
EOF
mkdosfs -F32 /dev/sdx1

    The 10 lines starting with 'fdisk /dev/sdx <<EOF' and ending with the 
    single word 'EOF' is actually one single command spread over ten lines,
    including the two empty lines in the middle.  This format is called a
    'here-document'.  It allows you to use a command which expects interactive
    input in a non-interactive way.  If you're uncomfortable with the above
    command you can just run

      fdisk /dev/sdx

    and create a partition interactively :-)

==========================================================
Author:   Eric Hameleers <alien@slackware.com> 17-feb-2011
Blog post: http://alien.slackbook.org/blog/installing-slackware-using-usb-thumb-drive/
Wiki URL: http://www.slackware.com/~alien/dokuwiki/doku.php?id=slackware:usbboot

