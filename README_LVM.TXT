
Installing Slackware on Logical volumes
=======================================


Introduction
------------

    For a long time, it has been common for other distros to support
installation to Logical Volumes.  In Slackware, the installer has never
supported this, but the gurus usually would find a way to create logical
volumes and install or migrate their Slackware onto those.  Having your
Slackware installed fully on LVM was near impossible until Slackware 12.0.
Slackware 13.37 has improved support for LVM built into the installer.


Preparing Logical Volumes (LV)
------------------------------

* Existing LV
    The Slackware installer will recognize and activate any pre-existing
Logical Volumes on your hard drive(s).  These Logical Volumes will be
selectable targets for the creation of the filesystems (like /, /usr, /home,
/var)

* New LV
    When you need to create the LV, you need to do this before starting the
'setup' program. You may have to run (c)fdisk first to create the partition
you want to use for setting up the logical volumes. For any partition you
create and that you want to use for LVM, you should set the partition type
to '8e' (Linux LVM).

    In the next example, I will assume we use a single 10 GB partition
'/dev/sda1' for our Volume Group (VG).  With LVM, it is possible to use
multiple physical volumes (i.e. partitions, whole disks) for a VG, but that is
left as an exercise for the reader.  You can always add extra physical volumes
to your VG later.  We will create a VG called 'myvg' and on that VG create two
LV's called 'root' and 'home'.  The first is going to contain the root partition
('/') and the second will become our '/home' partition.

    After booting your computer from the Slackware CD/DVD/USB, and logging in
as root, you run the following sequence of commands to create the Physical
Volume (PV), the Volume Group (VG) within that PV and two LV's of size 6GB
(root) and 3GB (home) inside the VG:

  # pvcreate /dev/sda1

  # vgcreate myvg /dev/sda1

  # lvcreate -L 6G -n root myvg

  # lvcreate -L 3G -n home myvg

    ========================================================================
    NOTE: if you want, you can just allocate all remaining space inside the
          VG to a Logical Volume.  Suppose we want to allocate all available
          space to our 'home' LV, then this will the command to use instead
          of the previous one (note the use of '-l' instead of '-L'):

            # lvcreate -l 100%FREE -n home myvg
    ========================================================================

    The device nodes for the logical volumes are created, and the volumes
will be activated automatically when running lvcreate.

This is all we need to do before running 'setup'.


Using LVM during setup
----------------------

    In setup, when you choose "TARGET" in the main menu, you will notice that
the LV's are available in the Linux partition selection.  Our two LV's "root"
and "home" are visible as "/dev/myvg/root" and "/dev/myvg/home".  Select the
first for your root ('/') filesystem, and the other for your /home filesystem.
Create any filesystem you like on them.  My favorite fstype still is ext3,
but you can choose ext4, xfs or jfs for stability and speed.

    Setup will proceed as usual, but when you get to the point where you are
presented with the lilo configuration dialog, it is almost time to perform
one final manual tweak.  Proceed with configuring your lilo as usual, and
select '/dev/myvg/root' as your root filesystem to boot.  When you install
lilo, it will probably not complain, but be aware that having your root
filesystem on a Logical Volume requires an initial ramdisk (initrd).  The
Slackware installer will not create it for you, and this requires some
manual intervention after the setup program has finished and you've been
returned to the command prompt.  For now, you can continue with the Slackware
setup as usual, but at the end, do not reboot just yet!

    At the end of the setup program it will prompt you to select "EXIT" and
press 'Ctrl-Alt-Del' to reboot the computer.  Exit the menu but DO NOT
reboot just yet!  At this point, we are going to create our initrd image.
Fortunately, the Slackware installer has done some of the work for us.
It will have created the LVM device nodes which lilo needs in order to
install successfully.  The installer will have mounted the /sys and /proc
filesystems as well.  Inside a 'chroot' we will create an initrd image
and configure lilo to use it with the generic kernel.  Be aware that
Slackware's 'huge' kernels are too big to work with an initrd image using
the lilo bootloader.  Lilo will complain that there is too little space
left in the 15M-16M 'memory hole'.
We are going to 'chroot' into our fresh installation:

  # chroot /mnt

    Next, while we are in the chroot, create the initrd with LVM support -
in the example command line I assume that the root filesystem is 'ext3',
we used the LV '/dev/myvg/root' as the root device, and are running the
Slackware 13.37 default SMP kernel '2.6.37.6-smp':

  # mkinitrd -c -k 2.6.37.6-smp -m ext3 -f ext3 -r /dev/myvg/root -L

    The resulting initrd image will be written to the file '/boot/initrd.gz'
by default.  We still need to tell lilo about this initrd, so open the
configuration file '/etc/lilo.conf' in an editor such as vi or pico - it
should already have been generated by the 'liloconfig' part of setup.  Look
for the "Linux bootable partition config" and add a line for the initrd.
Additionally, we change the filename of the kernel to be used. The default
filename added by 'liloconfig' is '/boot/vmlinuz' which is a symbolic link to
the huge SMP kernel.  Remember that we need a 'generic' kernel with the initrd.
The end result should look somewhat like this:

  image = /boot/vmlinuz-generic-smp-2.6.37.6-smp
    initrd = /boot/initrd.gz
    root = /dev/myvg/root
    label = linux
    read-only

    Double-check that the label you are using ('linux' in the above example)
is unique in the /etc/lilo.conf file.  If you are satisfied that everything
looks OK, write the changes, exit the editor and (re-) run lilo while in
the chroot.  Lilo will issue a couple of warnings concerning a difference in
what /proc/partitions reports and what lilo thinks are available partitions,
but it is safe to ignore these.

    =====================================================================
    An alternative method of creating the commandline for mkinitrd is
    to use the '/usr/share/mkinitrd/mkinitrd_command_generator.sh' script
    which is part of the mkinitrd package.  This script will analyze your
    Slackware installation and show you a useable 'mkinitrd' commandline:

    # /usr/share/mkinitrd/mkinitrd_command_generator.sh -r

    The above command would emit a commandline (almost) exactly as I
    showed earlier in this README.  If you are satisfied that it is the
    correct command for you, then there is no need to type it manually;
    just enclose the above line in "$()" which will actually run the command
    and create your initrd:

    # $( /usr/share/mkinitrd/mkinitrd_command_generator.sh -r )

    All that is left then is to update /etc/lilo.conf and run 'lilo'.
    =====================================================================

    You're done in the chroot now. Exit the chroot by running the command
'exit' and return the original console prompt (not that this looks any
different from the prompt inside the 'chroot' environment!).

    This completes the installation of Slackware.  Good luck with your fresh
'Slackware with a root filesystem-on-LVM' !


A word about using a Logical Volume for SWAP
--------------------------------------------

   The setup program is able to detect a Logical Volume and use it as a swap
partition, on the condition that you have manually formatted the LV as
swap before you start 'setup'.  That way, you will be able to select it as a
usable swap partition in the ADDSWAP section.  The setup program will inspect
all your logical volumes for a swap header.  Here is how you create the LV,
assuming you already created the Volume Group 'myvg' earlier - see above -
and left enough unallocated space in that VG:

  # lvcreate -L 1G -n swap myvg

This command creates a 1 GB large Logical Volume called 'swap' (but any
name will do) in the 'myvg' Volume Group.  Next, format the volume for
use as swap partition:

  # mkswap /dev/myvg/swap

This is enough to get it recognized by the setup program.  Have fun!


========================================================
Author:
  Eric Hameleers <alien@slackware.com> 08-apr-2011
Wiki URLs:
  http://www.slackware.com/~alien/dokuwiki/doku.php?id=slackware:setup
Documentation:
  /usr/doc/Linux-HOWTOs/LVM-HOWTO

