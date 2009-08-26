
This is an archive of the speakup project's GIT HEAD snapped on the given
day, and was used to build the speakup.s kernel.  Grabbing Speakup's GIT
repo (if you want the very latest) is done like this, by the way:

git-clone http://www.linux-speakup.org/speakup.git

To build the same kernel as Slackware included as speakup.s, you'll
need to do this:

Untar the speakup archive, and cd into the speakup directory:

tar xf speakup-3.0.3_20081026.tar.bz2
cd speakup-3.0.3_20081026

Patch whatever kernel you happen to want to compile:
./install /usr/src/linux-2.6.29.6

Change to the kernel directory:
cd /usr/src/linux-2.6.29.6

If you want to start with the defaults one of Slackware's kernels, you can do
that like this:

cat /boot/vmlinuz-huge-2.6.29.6 > .config

Or, better yet, if you have access to the Slackware tree use the
Speakup .config that was used:

cat (slacktree)/kernels/speakup.s/config > .config

Then do any additional configuation to the kernel that you may require:

make menuconfig

After that, it's build and install:
make
make modules_install
make bzImage
cat arch/x86/boot/bzImage > /boot/vmlinuz-huge-2.6.29.6-speakup

I put the -speakup on the end of the kernel name so that I can remember
which kernel I've patched, but that part is entirely optional.

The next step will be to edit add the new kernel's modules to an initrd if
you use one (if you didn't build in the root filesystem or something like
that you will need an initrd).  See "man mkinitrd" for more details on the
subject of making an initrd.

Now just add the new kernel (and possibly the /boot/initrd.gz) to
/etc/lilo.conf, run lilo as root, and you are ready to reboot.  Make sure
to use an append="speakup parameters" type line in /etc/lilo.conf to
configure speakup to use the proper synth driver.  You many also need to
specify the serial port or other parameters, like this:

append="speakup.synth=dectlk speakup.ser=2"

This line would attempt to use Speakup with a DecTalk Express on /dev/ttyS1.

Note that with Speakup 3.x, the kernel parameter names have changed to
contain dots rather than underscores.  Other options have changed as
well.  Although perhaps not a complete list, I found these changes noted
on the linuxfromscratch web site:

speakup_synth became speakup.synth, and the "sftsyn" synthesizer became "soft";

speakup_ser became speakup.ser, and serial ports are now numbered starting from 1,
not from 0 (i.e., speakup_ser=1 became speakup.ser=2);

speakup_quiet became speakup.quiet, valid values are 0 and 1;

speakup_port became speakup.port.

Good luck!  :-)

Pat

