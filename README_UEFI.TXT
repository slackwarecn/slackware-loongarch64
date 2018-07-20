
To use UEFI, or not to use UEFI?

Unless your computer came with a preinstalled version of Windows that
requires UEFI, switching to Legacy Boot (aka, traditional BIOS) is an
option.  Just switch to Legacy Boot in the UEFI menus.  With most systems
you can get into the UEFI menu by pressing the ESC key as the system
boots.  Then boot the Slackware installer and remove any existing
partitions using cgdisk to start over.  You may use either the GPT
partitioning scheme, or the traditional MBR partitioning scheme, but
there's really no advantage to switching back to MBR if your system
already has a GPT partitioned hard drive.  But...  if you want to do
that, you can.  To wipe out an existing GPT, use the gdisk command.
For example, to wipe /dev/sda:


gdisk /dev/sda
Enter 'x' to enable the entended options.
Enter 'z' to zap (wipe out) the existing GPT.
Answer 'Y' to add questions.


But I do want to use UEFI, and keep my existing Windows installation!

Great!  First things first.  You'll need to enter the UEFI menus and
disable Secure Boot, since Slackware does not currently work if Secure
Boot is enabled.  Windows will continue to work fine without it.

Then, you will probably need to shrink your main Windows partition, since
otherwise it is unlikely that you'll have any free space to install Linux.
To do this, boot the machine into Windows.  Move the mouse into the upper
right corner, and select the search function (magnifying glass icon).
Enter diskmgmt.msc to start up the Disk Management tool.  The disk
partitions will be displayed as a bar chart at the bottom of the window.
Mouse over the main Windows partition (probably the largest NTFS partition)
and right click to bring up a menu.  Select "Shrink Volume..." from this
menu.  Shrink the partition to make enough free space for Slackware's root,
swap, and other partitions.  Reboot the machine, and start the Slackware
installer from USB or DVD.  You might have to hit ESC and select your boot
device from the boot manager menu.  Now you're ready to install!

NOTE:  Rather than creating true free space, this resizing operation may
leave the extra space in the form of a generic (but allocated) partition.
Take note of the size of the "free space".  When it comes time to partition
on Linux, you may need to delete this partition to make actual free space
before you can install.

NOTE on starting the installer under UEFI:  Depending on your UEFI firmware
and the video card in your system, you might need to start the installer
with KMS (basically a kernel-based video driver) in order to have text
output.  If you boot and get screen garbage or no screen display then
try again using KMS.  From the DVD, select the KMS menu option.  From the
usbboot.img USB installer, hit TAB and then enter:  kms.s

OK, the installer is started, now what?

The next step is partitioning your system.  We'll assume that you want to
use GPT partitioning.  If you are installing to a machine that has Windows
installed, then you'll already have an EFI System Partition (this is used
to store boot files on machines that use UEFI).  To check this, you can use
gdisk.  We'll assume that you'll be installing to /dev/sda.  If you'll be
installing to some other device, use that in the command below.

gdisk -l /dev/sda

If you see a partition with Code EF00 listed, then you are good to go.
If not, you will need to make one.  To do that, use cgdisk:

cgdisk /dev/sda

Select the free space from the menu using the up/down keys, and then select
"New" to make a new partition.  Hit ENTER to accept the first sector.  Then
enter 100M as the partition size.  Give the new partition a hex code of EF00.
You may give the partition a name (such as "EFI System Partition"), or just
hit ENTER to use no name.  A name is not required.

At this point, you've got a GPT disk with an EFI System partition (with or
without Windows).  The next step is to make the partitions for Linux.  If
you're not already in cgdisk, start that up with "cgdisk /dev/sda" (or
whatever your install device is).  Start by making a swap partition.  A
good rule of thumb is to make the swap partition equal to the amount of RAM
in your machine.  So, select the free space again, and then "New".  Again,
hit ENTER to accept the default first sector for the new partition.  Then,
enter an appropriate size, such as 2G.  Enter the hex code for Linux swap,
which is 8200.  Give the partition a name if you like.

Make your root Linux partition (optionally if you leave some space you can make
any additional Linux partitions that you'll need).  Select the free space, and
"New".  Accept the default first sector by hitting ENTER.  To make the
partition use the rest of the disk space, just hit ENTER again when asked for
a size.  Or, you may choose a smaller size if you're planning to make more
Linux partitions.  Hit ENTER to accept the default hex code, which is for a
Linux filesystem.  Name the partition (if you like), or hit ENTER again.

If you have any more free space and partitions to make, now is the time to
make them.

When you're done, select "Write" to write the partition table changes to the
disk (verify by typing "yes" when prompted), hit a key to continue, and then
select "Quit" to leave cgdisk.

Now you're ready to begin the installation by running the "setup" command.
You'll notice that after choosing your Linux partitions, the EFI System
Partition will be detected by setup and added to your /etc/fstab to be mounted
on /boot/efi when the system starts.

After the packages are done installing, the other difference in a UEFI
installation is the setting up of the bootloader.

First up, making a USB boot stick.  The script to make the stick will add
a UEFI bootloader to it by default, and the stick will work with either UEFI
or regular BIOS.  It is highly recommended that you make a USB boot stick so
that you have a way to boot your system easily.  On some machines, adding a
boot entry to the UEFI boot menu doesn't work so well.  So, make the stick.
When it saves you later on, you won't regret the effort.

Since LILO doesn't work in pure UEFI mode, setup will recommend not installing
it.  You can still install it if you like, though.  It would only be useful if
you boot the machine in Legacy BIOS mode.  If you're not planning to do that,
go ahead and skip LILO.

Next, you'll get a menu prompting you to set up ELILO.  ELILO is a bootloader
that is similar to LILO but that was written to support EFI machines.  Go
ahead and tell the system to install ELILO, and it will set up ELILO in
/EFI/Slackware on your EFI System Partition, along with a kernel and an ELILO
configuration file.  Next you'll be asked if you want to install a new menu
entry for your Slackware system in your UEFI firmware.  Unless you are using
an Intel Mac, it is suggested that you do this.  Without such an entry, you
would have to press ESC (or possibly DEL or a function key) to enter the UEFI
menu, use the firmware to "boot from a file", navigate through the EFI System
Partition directories to the /EFI/Slackware/bootx64.efi file and then select
it to boot Slackware.  If you are using an Apple Intel Mac, DO NOT TRY TO
INSTALL A MENU ENTRY!  It would probably brick your firmware requiring Apple
to service the machine to reflash the firmware.  On other machines that use
UEFI, it is highly recommended to add the menu entry to make it easier to
chose an operating system at boot.

If the menu entry doesn't work on your system, you can still force your
machine to boot ELILO automatically by copying the files in /EFI/Slackware on
your EFI System Partition to /EFI/BOOT on your EFI System Partition, and 
renaming /EFI/BOOT/elilo.efi to /EFI/BOOT/BOOTX86.EFI.  Before doing this,
you might want to back up any existing files in /EFI/BOOT.

Once you've finished up the post installation menus, you'll be ready to reboot
your machine and enjoy your new Linux system.

Have fun!

