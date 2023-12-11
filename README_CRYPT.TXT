
Installing Slackware on encrypted volumes
=========================================


Contents:

* Introduction
* Using cryptsetup during Slackware installation
* Encrypting your '/home' partition
* Encrypted swap
* Encrypted root filesystem
* Combining LUKS and LVM
* Hibernation (suspend-to-disk)
* Additional passphrases, keyfiles
* A note on custom kernels
* USB keyboards and LUKS
* A mkinitrd helper script


Introduction
------------

    Increasingly common in modern Linux distributions is the ability to
install onto an encrypted partition (or drive, or volume).  Especially for
people with a laptop who are traveling a lot, it adds a lot to the security
of your data if access to that data is denied to the potential thief of
your computer.

    Starting with release 12.0, Slackware has support for LVM built into the
installer.  With a little more effort, the installer offers the opportunity to
use transparent encryption on the partitions/volumes/disks where you install
Slackware.  You can combine the use of LVM and encryption to minimize the
number of times you need to enter an unlock passphrase.  If you want to know
more about setting up and using LVM during the installation, read the file
'README_LVM.TXT'.

    Slackware uses device-mapper and cryptsetup to achieve transparent
encryption of your data partitions and your swap.  Cryptsetup uses a
concept called LUKS (Linux Unified Key Setup) which enables you to change
your unlock password for the encrypted volume without having to re-encrypt
all of your data. You can even assign multiple passphrases to an encrypted
volume, so that other people besides you are able to unlock the encryption
without the need to know _your_ passphrase.

    When preparing a partition for transparent encryption with cryptsetup,
the program will ask you for a password. This password is used to encrypt
another randomly generated password and this particular password is used
to actually encrypt the data inside the mapped volume. Cryptsetup will
create a mapped device and make this block device available under the
'/dev/mapper' directory. Any data read from or written to this mapped device
will automatically be decrypted from / encrypted to the actual partition.

    A big NOTE finally. When you encrypt your root filesystem, you will have
to make sure that there will be at least one (small) partition which is
left unencrypted. This partition must contain the kernel(s) you want to boot
from, and the initrd image that is needed with encrypted volumes. You need
to install LILO either to the MBR - or if that is not possible, into the
root sector of this small unencrypted partition. You will probably guess
why we cannot use an encrypted partition for this...


Using cryptsetup during Slackware installation
----------------------------------------------

    We are going to enable encryption on some or all of our partitions or
volumes before installing Slackware onto them.  The first section to follow
deals with encrypting a single partition which is not the root partition.
Typically, people have a need to encrypt their home directories and that is
where that section will focus on.  Next is a section on encrypting your
swap partition in addition to your /home partition.  The swap partition
contains valuable information for a data thief, even after you power off
your computer.  By encrypting the swap partition we deny the potential thief
access to this data.  The section following that will show you how to get
a fully encrypted system, by encrypting the root ('/') filesystem as well.
This is a little harder to do, but probably worth the effort.

    To make it more interesting, _and_ easier to use, we will devote a final
section to using a combination of LVM and disk encryption.  As an example,
we will create a single big encrypted partition, and inside that encrypted
'container' we create several Logical Volumes which we will use as our root
(/), /home and swap partitions.  The advantages of this approach are, that you
will need only a single passphrase to unlock your computer, and you will not
have to maintain an '/etc/crypttab' file containing information about encrypted
volumes that need to be unlocked during boot-up.  Additionally, we will be
rewarded with a swap partition that we can use for suspend-to-disk and that
will remain encrypted after shutdown (so that for instance a potential data
thief will not be able to get to your valuable data even if you hibernated
your laptop).

    If you choose this last option to get a fully encrypted Slackware, it is
advisable to read the 'README_LVM.TXT' file to make yourself more familiar
with the process of creating and using Logical Volumes during installation
of Slackware.  And then, skip right through to the section of this document
called "Combining LUKS and LVM".


Encrypting your '/home' partition
---------------------------------

    After the computer boots up from the install CD/DVD (or USB flash disk,
or PXE) and you find yourself at the '#' prompt, the first thing to do is
use 'fdisk' or 'cfdisk' to create any partitions you need for your Slackware.
Next, use 'cryptsetup' to prepare the partitions you intend to be
encrypted.  Note: this section of the README concerns itself with setting
up encrypted *data* partitions. If you want to know how to configure an
encrypted *swap* partition, skip to the section called "Encrypted swap".

    Suppose, you want to encrypt the partition called '/dev/sdx2' and use it
as your '/home' filesystem. (Please replace '/dev/sdx2' with the name of YOUR
PARTITION in the next series of examples). Several of the commands shown below
will irrevocably destroy any data that you currently have on the partition. It
is a good idea to double check the output from 'fdisk -l' before you start.

* To begin with, we are going to fill the partition with random data. This
will make it a lot harder for any forensics expert to determine where your
encrypted data resides on that partition after we're finished installing
Slackware onto it. The process will take a long time - depending on the
size of your partition it may take hours or more. if you're not _too_
concerned with the possibility of an FBI agent confiscating your computer,
you can skip this command:

  # dd if=/dev/urandom of=/dev/sdx2

* Prepare the partition for encryption. You will be asked twice to enter
a passphrase. Note that a passphrase is not limited to a single word. The
passphrase may contain spaces.

  # cryptsetup -y luksFormat /dev/sdx2

You can dump information about the encrypted partition to your console by
running the following command:

  # cryptsetup luksDump /dev/sdx2

* Now we will 'open' the encrypted partition and let the devicemapper create
a mapped block device. We will use the mapped device which behaves just like
an ordinary disk partition when we get to the TARGET selection in 'setup'. The
mapped device nodes will be created in the directory '/dev/mapper'. The command
will ask you for the passphrase which you entered during the "luksFormat"
operation. The last argument that the command takes is the name of the mapped
device. We will call our mapped device 'lukssdx2' (note that LUKS expects the
mapped device name to be in the format of "luks<rawdevname>"). It will be 
available for use as the block device '/dev/mapper/lukssdx2', e.g. if the raw
device name is "/dev/sda2", then the mapped name will be "/dev/mapper/lukssda2".

  # cryptsetup luksOpen /dev/sdx2 lukssdx2

* We've now finished our preparations, and it is time to start the 'setup'
program and install Slackware.  This setup does not differ at all from the
setup you have become used to.  The only notable difference lies in the
names of the devices you will select for your target partitions.  Be sure
to read until the end of the story though, because we will have to do some
postprocessing in order to make your encrypted partitions available after
reboot (setup cannot yet do all of this automatically).

* In setup, under "ADDSWAP", proceed as usual and configure a normal
unencrypted swap partition, even if you want to have your swap encrypted.
We will take care of swap encryption after the installation of Slackware
finishes.

* In setup, when you choose "TARGET" in the main menu, you will notice that
the mapped device is available in the 'Linux partition' selection as
"/dev/mapper/lukssdx2".  Select the partition you designated for your
root ('/') filesystem, and next select "/dev/mapper/lukssdx2" for your
'/home' filesystem.  Create any filesystem you like on them.  My favorite
fstype is ext4, but you can choose xfs or jfs for stability and speed.

NOTE: The underlying partition will *also* be visible in the target selection
      menu. Be very careful NOT to select this device ('/dev/sdx2' in our
      example) for any other filesystem you wish to create, or you will
      destroy the data on the encrypted partition.

* Let the installation complete, and after you select "EXIT" make sure to
choose not to reboot and you will be returned to the command prompt.  DO
NOT reboot just yet!  We are going to create a configuration file for
the cryptsetup program, called '/etc/crypttab'.  This file contains the
information cryptsetup needs for unlocking your encrypted volume and mapping
it to the correct device name.  The file '/etc/crypttab' contains lines of the
format: "mappedname devicename password options".  Since we are still inside
the installer, the root filesystem of our fresh Slackware installation is
still mounted under '/mnt'.  For our example where we encrypted '/dev/sdx2'
and mapped the unlocked device to '/dev/mapper/lukssdx2', we need this
single line in '/etc/crypttab':

lukssdx2	/dev/sdx2

So, we need to run the command:

  # echo "lukssdx2   /dev/sdx2" > /mnt/etc/crypttab

in order to create the file with the required content (I am assuming here
that the file did not yet exist... the above command will overwrite the
data in the file should it have existed).  You can of course also just
start the 'vi' editor and add the above line.  When the password is not
listed in the crypttab file (potentially very unsafe of course) cryptsetup
will ask you for the password when your computer boots.


Encrypted swap
--------------

    In the previous chapter we have installed Slackware using an encrypted
/home partition, but left the swap partition unencrypted.  We are going
to take care of that 'omission' right now, because we do not want to give
a potential data thief access to any sensitive data which landed on your
disk because of the kernel's memory swapping process.

It really is very simple and straight-forward.  It is also independent of
whether or not you are using encryption for any other (data) partition.
Add the following line to the 'crypttab' file on your fresh installation
of Slackware - for the sake of this example I am assuming that the swap
partition you chose is '/dev/sdx3':

cryptswap   /dev/sdx3   none   swap

You can use the 'vi' editor to add this line to '/mnt/etc/crypttab'.
You can also choose to run the following command which adds that line to
the end of the file:

  # echo "cryptswap   /dev/sdx3   none   swap" >> /mnt/etc/crypttab

We need to edit the 'fstab' file of your Slackware installation so that
the correct device will be used for the swap after your computer reboots
(the device '/dev/sdx3' will no longer be useful, but '/dev/mapper/cryptswap
will'). The line in '/mnt/etc/fstab' for your swap will look like this at
first:

/dev/sdx3   swap   swap   defaults   0   0

and you will have to change it so that it becomes like this:

/dev/mapper/cryptswap   swap   swap   defaults   0   0

    These two edits are sufficient.  The above instructions assume that you
edited the 'crypttab' file at the end of a Slackware installation, but in
fact you can do this at any time.  The Slackware boot-up process will
take care of the rest.  At shutdown of your Slackware, the encrypted swap
partition will be reformatted as a normal unencrypted swap, so that any
other OS-es you might be running in a multi-boot configuration will have
no problems in using this swap partition as well.

NOTE: the swap partition is encrypted with a new randomly generated key every
      time your computer boots.
      There is no need to ever enter a passphrase!

NOTE: having an encrypted swap like this causes a re-format of the swap
      partition on every boot-up and shutdown.  This is perfectly OK as long
      as you do not change the order of your hard disks.  If you add a disk,
      or move this disk to another computer, the device name may change (for
      instance from sda to sdb) and if you forget to modify '/etc/crypttab'
      your system may end up formatting the wrong partition!
      For this reason alone, it is recommended that you implement disk
      encryption including swap using the "Combining LUKS and LVM" method
      described in the chapter with the same name!


Encrypted root filesystem
-------------------------

    You can go one step further than merely encrypting your '/home'
filesystem's partition.  You can choose to encrypt _all_ of your Slackware
partitions, including the root partition.  In that case you will have to
perform some additional post-install configuration before you reboot your
Slackware box.

NOTE: the method described here will result in having several independently
      encrypted partitions.  This may require you to enter multiple
      passphrases in order to unlock all of these partitions.  If you want to
      unlock your complete system using a single passphrase, and if you do
      not shy back from using LVM, then the better alternative is to follow
      the instructions in the "Combining LUKS and LVM" chapter which follows
      next.  If you think that LVM adds one layer of complexity too much,
      then just read on and implement the solution described right here.

* Be sure to create a small partition which you leave *unencrypted*.  Tell
the installer to mount it under '/boot'.  The kernel and the initrd (with
the cryptsetup and additional required kernel modules) will go there.  We are
going to assume that Slackware is the only OS on the computer so that you
can tell lilo to install the bootloader in the MBR (which is the default
option).  Lilo is able to boot a Windows if you already had that installed on
your computer, so even in the dual-boot situation it should be safe to use
the MBR.  With other Linux distributions already present on the computer,
things may be a little more difficult - you will have to install lilo to
the /boot partition then.

* Perform a Slackware install just like I described above, creating
additional encrypted partitions and mapping them to appropriate names -
for this example I assume that you map the encrypted root partition
'/dev/sdx2' to 'lukssdx2'.  When the LILO configuration pops up, tell lilo
that your root partition is '/dev/mapper/lukssdx2'.  Lilo will try to
install and fail, and will tell you so.  It will however have written a
'lilo.conf' file which we can edit in a follow-up action.  Proceed with
the installation and at the end, exit the setup program but do _not_
reboot just yet.

* After you are returned to the command prompt, perform a 'chroot' into the
new installation.  All the filesystems are still mounted, and the Slackware
installer will already have mounted the /sys and /proc filesystems for use
in the 'chroot'.  We only need to run the following command:

  # chroot /mnt

* Next, now that we are in the chroot, create the initrd with LVM (if you
used Logical Volumes) and CRYPT support - or else your Slackware computer
will not be able to proceed past the initial stage of booting the kernel.
The initial ramdisk (initrd) contains a small filesystem with the tools
needed to unlock the root filesystem, so that the kernel can start the init
program.  In the example command line below which creates the 'initrd.gz'
image I assume that the root filesystem is 'ext4', we used the mapped device
'cryptroot' for the root filesystem on the real partition '/dev/sdx1',
and are running the Slackware 14.2 default kernel '4.4.14'
and we did not use Logical Volumes (more about that in the next section):

  # mkinitrd -c -k 4.4.14 -m ext4 -f ext4 -r lukssdx2 -C /dev/sdx2

* The resulting initrd image will be written to the file '/boot/initrd.gz'
by default.  We still need to tell lilo about this initrd. Open the
configuration file '/etc/lilo.conf' in an editor such as vi or pico -
it should already have been generated by the 'liloconfig' part of setup.
Look for the "Linux bootable partition config" and add a line for the initrd.
We also need to change the kernel file to a generic kernel, because lilo
is unable to combine the 'huge' kernels in Slackware 14.0 with an initrd
image - it will complain about "The initial RAM disk is too big to fit
between the kernel and the 15M-16M memory hole" if you try with a 'huge'
kernel.  We can live with that, since the 'huge' kernels are not meant
for day-to-day use anyway.  They are meant to install Slackware on a wide
range of computers and that is why they are 'huge'.  The linux part of
'/etc/lilo.conf' should end up looking somewhat like this:

image = /boot/vmlinuz-generic-4.4.14
  initrd = /boot/initrd.gz
  root = /dev/mapper/lukssdx2
  label = linux
  read-only

If you add the above section as an extra instead of editing what's already
present, make sure that the label you use ('linux' in the example above)
is unique in the configuration file.

* If you have another OS on your computer and cannot install lilo to the
MBR, you will have selected "Install to superblock (Root)" instead.  In
that case, we have one additional change to make, and that is almost at the
top of the file.  Look up the line that says "boot = /dev/mapper/lukssdx2"
which is the device for your root partition and which was the reason for
lilo failing to install.  Change the boot device to the name of the small
*unencrypted* partition you've created at the beginning and which is
mounted under '/boot'.  Assuming the name of that partition is '/dev/sdx1',
the "boot =" line must become like this:

  boot = /dev/sdx1

We are done.  Write the changes, exit the editor and run the command 'lilo'.
Lilo will issue a couple of warnings concerning a difference in what
'/proc/partitions' reports and what lilo thinks are the available partitions,
but it is safe to ignore these.
Reboot now, and you will be presented with a "Enter passphrase: "
prompt.  After entering the passphrase which unlocks your root filesystem,
the system will boot into Slackware.  If there are other encrypted partitions,
you will be prompted for their respective passphrases, too.


Combining LUKS and LVM
----------------------

    Until now, we have been occupying ourselves with encrypting separate
partitions.  This is all fully functional, but there are a few drawbacks.
One, you will need to enter a passphrase for every partition you have encrypted
(except for the swap which Slackware encrypts with a random passphrase
on every boot).  Two, the method used for encrypting the swap partition
prohibits the use of the swap as a hibernation partition.  And since the
initrd of Slackware 14.0 supports hibernation, it would be a shame not to be
able to use this feature on your laptop (which, because of it's portability,
is the primary target for full disk encryption anyway).

    This section of the README_CRYPT.TXT will deal with these drawbacks and
offer you full disk encryption (including swap) that needs only a single
passphrase to unlock and allows for hibernation (suspend-to-disk).

    We are assuming that Slackware will be the only Operating System on your
computer.  In case you already have an OS installed (such as MS Windows), the
procedure may be a little different because you cannot always install lilo to
the MBR.  After booting from the Slackware installation medium, we will
create a small unencrypted partition that will contain the Linux kernels and
the initrd image(s).  The rest of the disk's free space will be dedicated to
a single partition which we are going to encrypt.  On top of the encrypted
volume, we are going to create several Logical Volumes, and these LV's
are going to be formatted as our Slackware partitions ('/', '/home' and
'swap').  These are the steps in more detail:

* Use (c)fdisk to create your partitions. For the sake of this example, I
am going to assume that /dev/sdx1 is a 100 MB large partition and /dev/sdx2
is the large partition that eats up the remainder of your disk's free space.

* First, create a LUKS-encrypted volume on top of /dev/sdx2 after you
have optionally filled the partition with random data (read the section
"Encrypting your '/home' partition" for more information about why you
would want to fill your partition with random data first):

  # dd if=/dev/urandom of=/dev/sdx2

* Prepare the partition for encryption. You will be asked twice to enter
a passphrase.  Note that a passphrase is not limited to a single word.  The
passphrase may contain spaces.

  # cryptsetup -y luksFormat /dev/sdx2

* Open the encrypted partition so that we can start using the mapped device
which exposes the partition as an unencrypted block device.  The command
will ask you for the passphrase which you entered during the "luksFormat"
operation.  The last argument that the command takes is the name of the mapped
device.  We will call our mapped device 'lukssdx2' because the installed 
system will use that name (predictability is a good thing).

  # cryptsetup luksOpen /dev/sdx2 lukssdx2

* The LVM part is next.  Create a Physical Volume (PV) on device
'/dev/mapper/lukssdx2', a Volume Group (VG) called 'cryptvg' - any name will
do - on the PV, and three Logical Volumes (LV's) in the VG, one for your
root partition (7 GB in size), one for the /home partition (10 GB in size)
and a third which we will use for swap (1 GB in size).  You will probably
use different sizes depending on your environment and wishes, but keep the
sum of the LV sizes less than the total size of the Physical Volume:

  # pvcreate /dev/mapper/lukssdx2

  # vgcreate cryptvg /dev/mapper/lukssdx2

  # lvcreate -L 7G -n root cryptvg

  # lvcreate -L 10G -n home cryptvg

  # lvcreate -L 1G -n swap cryptvg

* Run 'mkswap' so that the 'setup' program will identify the 'swap'
LV as a valid swap partition:

  # mkswap /dev/cryptvg/swap

* With the system properly prepared, you can launch 'setup'.  The 'setup'
program will identify the LV swap volume and activate it.  When appointing
the partitions to use for your filesystems, select '/dev/cryptvg/root' for the
root partition, next select '/dev/cryptvg/home' to be used for your /home .
And lastly, assign the partition /dev/sdx1 to a /boot filesystem.  This
'/boot' filesystem will be the only unencrypted part of your computer.

    You will notice that there are several more devices to select from but
*don't* touch these!  The devices such as /dev/mapper/* are the underlying
device names for the encrypted and LVM volumes.  If you choose to touch any
of these, you will destroy the data on the /dev/cryptvg/* volumes which you
are using.
After partitioning, we end up with a filesystem configuration like this:

  /dev/cryptvg/root  /
  /dev/cryptvg/home  /home
  /dev/sdx1          /boot 

* When installation of the packages has finished, the system configuration will
start, and one of the dialogs will be for 'liloconfig'.  The assumption is that
you are installing Slackware as the only OS on your computer.  This means that
you must install lilo to the MBR.  Even if you have another OS like MS Windows
installed already, Slackware's lilo bootloader will be able to boot Windows
if you install lilo to the MBR.  Choose "expert lilo configuration" with the
option "Install to Master Boot Record (MBR)".  Select '/dev/cryptvg/root' as
the root partition to boot.  Add any Windows partition to lilo if you want to
dual-boot Windows.  Finally, when liloconfig installs the bootloader, you may
see an error message stating that the "installation failed".  Ignore this,
because we will have to add an initrd to '/etc/lilo.conf' anyway and re-run
lilo.  We will do this after the Slackware installation has come to it's end.

* Let the installation complete, and after you select "EXIT" you will be
returned to the command prompt.  DO NOT reboot just yet!  This is the moment
where we fix our bootloader.  To do so, we will 'chroot' (change root) into
our freshly installed Slackware filesystem.  The setup program has done all
the preparations already, such as re-mounting /sys and /proc below /mnt and
generating LVM device nodes in /mnt .  Enter the 'chroot' using the command:

  # chroot /mnt

* In the chroot, you create an initrd image with LVM and CRYPT support -
or else your Slackware computer will not be able to proceed past the initial
stage of booting the kernel.  The initial ramdisk (initrd) contains a small
filesystem with the tools needed to unlock the root filesystem, so that
the kernel can start the init program.  In the example command line below
which creates the 'initrd.gz' image I assume that you formatted the root
filesystem as 'ext4', and will be running the Slackware 14.2 default
kernel '4.4.14' :

  # mkinitrd -c -k 4.4.14 -m ext4 -f ext4 -r /dev/cryptvg/root -C /dev/sdx2 -L

NOTE: if you use a non-US keyboard and need to enter a passphrase during boot,
      this may be problematic if the keyboard mapping is US while Slackware
      runs from the initrd filesystem.  In this case, add support for your
      keyboard to the initrd image using this additional parameter to the
      'mkinitrd' command above: "-l <language>". The string <language> is the
      same as the one you select in the installer when your keyboard is
      non-US.  Example for a dutch keyboard: "-l nl".

* The resulting initrd image will be written to the file '/boot/initrd.gz'
by default.  We still need to tell lilo about this initrd, so open the
configuration file '/etc/lilo.conf' in an editor such as vi or pico -
it should already have been generated by the 'liloconfig' part of setup.
Look for the "Linux bootable partition config" and add a line for the initrd.
We also need to change the kernel file to a generic kernel, because lilo
is unable to combine the 'huge' kernels in Slackware 14.2 with an initrd
image - it will complain about "The initial RAM disk is too big to fit
between the kernel and the 15M-16M memory hole" if you try a 'huge'
kernel.  We can live with that, since the 'huge' kernels are not meant
for day-to-day use anyway.  They are meant to install Slackware on a wide
range of computers and that is why they are 'huge'.  The linux part of
'/etc/lilo.conf' should end up looking somewhat like this:

image = /boot/vmlinuz-generic-4.4.14
  initrd = /boot/initrd.gz
  root = /dev/cryptvg/root
  label = linux
  read-only

    If you add the above section as an extra instead of editing what's
already present, make sure that the label you use ('linux' in the example
above) is unique in the configuration file.

    We are done.  Save your changes, exit the editor and run the command
'lilo'.  Lilo will issue a couple of warnings concerning a difference in
what '/proc/partitions' reports and what lilo thinks are the available
partitions, but it is safe to ignore these.  Reboot now, and you will be
presented with a "Enter passphrase: " prompt.  After entering the passphrase
which unlocks your encrypted partition, the system will boot into Slackware.
You will be able to work as usual, and when you shut the machine down (or
suspend to disk using the swap partition) all your data (including swap)
will be encrypted when stored on disk.

    As you may have noticed, there was no need to create a file '/etc/crypttab'
this time.  Also, there is only a single passphrase to enter. Additionally,
the swap is encrypted by default which is a big plus if you intend to use a
laptop and carry it around with you in a hibernated state.  All considered,
this is the most elegant way of encrypting your Slackware computer if you
do not mind using LVM.


Additional passphrases, keyfiles
--------------------------------

    The cryptsetup program assigns 7 'key slots' to any partition or volume
it encrypts.  Each of those seven slots can contain a key to unlock the
partition's data.  The key can be a passphrase, but the content of a
*keyfile* is another option.  You can then pass the name of a file as a
parameter to cryptsetup in order to unlock an encrypted volume so that
you won't have to type a passphrase.  This creates the possibility to
use a keyfile on a removable USB flash disk for unlocking your Slackware
computer.  Slackware supports keyfiles: if the file can be found on the file
system, it will be used and you won't have to type a passphrase.

    A keyfile on a FAT formatted USB stick can be used as well.  This scenario
requires you to use the "-K" parameter to mkinitrd to specify the USB stick's
FAT-label or UUID, as well as the full path to the keyfile.  An example:

  # mkinitrd -c -k 4.4.14 -m ext4 -f ext4 -r /dev/cryptvg/root -C /dev/sdx2 -L -K LABEL=TRAVELSTICK:/keys/alien.luks

    The mkinitrd of Slackware 13.1 introduced this support for USB sticks as
unlocking mechanism.  Alternatively, after the root filesystem is unlocked
and mounted, it is completely safe to have a keyfile for _additional_
encrypted filesystems stored in for instance the '/root' directory.
That way, you still have only one passphrase to type.


Hibernation (suspend-to-disk)
-----------------------------

    I will touch briefly on the subject of enabling 'suspend-to-disk'
because it is not documented properly anywhere else.  Configuring your
Slackware computer for hibernation can be done at any time, it is not
required to do this during installation of Slackware.  Suppose you want
to use the swap partition '/dev/cryptvg/swap' for hibernation, then you
must perform the following two steps:
(1) add "resume=/dev/cryptvg/swap" to the 'append =' line in your
    '/etc/lilo.conf' file.  The 'append' line may end up looking like this:
      append = "vt.default_utf8=0 resume=/dev/cryptvg/swap"
(2) add "-h /dev/cryptvg/swap" as an extra parameter to your mkinitrd command
    to create an initrd with support for resuming from a swap partition.
    Do not forget to run 'lilo' after creating the new initrd.gz file!


A note on custom kernels
------------------------

    If you want to compile your own custom kernel to work with LUKS encrypted
partitions, you need to enable at least the following two options in your
kernel configuration:

Multiple devices driver support (RAID and LVM) --->
 <*> Device mapper support
 <*> Crypt target support

This is equivalent to the following options in your .config file:

CONFIG_BLK_DEV_DM=y
CONFIG_DM_CRYPT=y

Do not compile these as module! They are required in your kernel. 


USB keyboards and LUKS
----------------------

    If you have set up an encrypted root partition, you will need to have
access to your keyboard in order to type the passphrase.  This may require
you to add the 'uhci-hcd' and 'usbhid' modules to your initrd image if you
have a USB keyboard.  Also note that if you are using a non-US keyboard,
you can use the '-l' parameter to the 'mkinitrd' command in order to add
support for this keyboard to your initrd.


A mkinitrd helper script
------------------------

    The mkinitrd package in Slackware 14.0 (and on) ships with a script called
'mkinitrd_command_generator.sh'.  If you run this script, it will analyze
your Slackware configuration and make a smart suggestion about the 'mkinitrd'
command you have to type in order to create an initrd.gz with all the bells
& whistles.  The script will recognize your kernel version, root partition
and filesystem, it will find out if you are using LUKS and/or LVM and will
determine what kernel modules your initrd needs to mount the root filesystem.
The following command will save you the headache of figuring this out all
by yourself:

  # /usr/share/mkinitrd/mkinitrd_command_generator.sh -r

It should emit a string like this (your system will probably give different
parameter values):

mkinitrd -c -k 4.4.14 -m ext4 -f ext4 -r /dev/cryptvg/root -C /dev/sdx2 -L

You can copy and paste this output to your command prompt, and add any other
parameters you need such as "-h" to indicate a hibernation partition or
"-l" to indicate you are using a non-US keyboard layout.  You can even run
the script in full interactive mode by using the "-i" parameter, and it will
guide you through the process of generating a mkinitrd commandline.


Desktop Environments
--------------------

     You probably will not want your encrypted volume to appear on the desktop
of e.g. KDE or Xfce as a mountable device, so something like this should 
prevent that from occurring:

# cat /etc/udev/rules.d/99-ignore-luksdevs-on-desktop.rules
KERNEL=="sdx2", ENV{UDISKS_IGNORE}="1"


==============================================================================

Good luck with your fresh Slackware installion on encrypted partition(s)!

==============================================================================
Author:
  Eric Hameleers <alien@slackware.com> 18-sep-2012
Edits by:
  Robby Workman <rworkman@slackware.com> 9 March 2017
URLs:
  http://www.slackware.com/~alien/dokuwiki/doku.php?id=slackware:setup

