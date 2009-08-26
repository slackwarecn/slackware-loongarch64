
Here are a set of 2.6.30.5 Linux kernel packages available for testing
with Slackware 13.0.  These are not supported kernels, and we would
recommend that most users stick with the 2.6.29.6 kernels unless they
have a reason to use the newer kernel.  A possible reason might be if
a system has some hardware that is better supported by the latest
kernel, such as certain recent wifi and video drivers.

That said, we hope these kernel packages are helpful.

To use these packages, install them with installpkg:

installpkg kernel-*.txz

Then, use mkinitrd to make an initial ramdisk.  Use appropriate settings
for the kernel, filesystem module and type, and root device.  Here's an
example for the i686 generic kernel using ext4 on root device /dev/sda2:

mkinitrd -k 2.6.30.5-smp -m ext4 -f ext4 -r /dev/sda2

Here's an example using the x86_64 generic kernel and ext4 on /dev/sda2:

mkinitrd -k 2.6.30.5 -m ext4 -f ext4 -r /dev/sda2

Now, you'll need to edit your /etc/lilo.conf.

**************
* IMPORTANT! *
**************

Due to the size of the 2.6.30.5 kernel and initrd, many BIOSes cannot boot
the kernel/ramdisk combination for i686, and most (if not all) will have
problems with the x86_64 kernel/ramdisk unless this option is added to the
/etc/lilo.conf:

large-memory

This allows LILO to use more than the first 15MB of RAM.  LILO does not use
this option by default since it doesn't work with some older systems (BIOSes
from before around 2001).  LILO tries to detect the amount of space that will
be required to decompress the kernel, but some adjustment to the code is
going to be needed, or perhaps we will have to investigate alternatives for
the bootloader.  In any case, that's something for Slackware 13.1 or 14.0, or
whatever happens down the line.

The option can go into the lilo.conf global section.  It actually works just
fine to make it the first uncommented line of the file.

**************

Editing the /etc/lilo.conf file:

With the large-memory option added to the file as described above, the next
step is to add a section to boot the new kernel and initrd.  It's probably
a good idea to leave the section that boots the existing kernel in place at
first.

An example for the 2.6.30.5-smp i686 kernel might look like this, added to
the bottom of /etc/lilo.conf:

# Linux bootable partition config begins
image = /boot/vmlinuz-generic-smp-2.6.30.5-smp
  initrd = /boot/initrd.gz
  root = /dev/sda2
  label = L26305
  read-only
# Linux bootable partition config ends

This uses the same configuration as the mkinitrd example for i686 above --
adjust it to suit your needs.

Once you've edited /etc/lilo.conf to add a boot section for the new kernel
and the large-memory option, you're ready to reinstall LILO.  As root,
issue the "lilo" command.  You should see output similar to this:

# lilo
Warning: LBA32 addressing assumed
Added Linux *
Added Windows
Added L26305
One warning was issued.

If you get an error (not just a warning), you'll need to figure out how to
correct that and install LILO again BEFORE you try to reboot the machine!
Otherwise the machine may not reboot, and you'll need to use bootable media
to rescue it.

Once LILO is installed without errors (warnings are probably OK), you may
reboot the machine and select the menu option for the new kernel.  If all
goes well, your machine will start up running the 2.6.30.5 kernel.

Hope this helps, and have fun.  :-)

