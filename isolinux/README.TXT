
HOW TO MAKE A BOOTABLE SLACKWARE DVD ISO IMAGE

To make a bootable Slackware install DVD, get into the top level Slackware
directory (The one with ChangeLog.txt in it) and issue a command like this
to build the ISO image in /tmp:

mkisofs -o /tmp/slackware-dvd.iso \
  -R -J -A "Slackware Install" \
  -hide-rr-moved \
  -v -d -N \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -sort isolinux/iso.sort \
  -b isolinux/isolinux.bin \
  -c isolinux/isolinux.boot \
  -m 'kde-l10n-*.tar.bz2' \
  -V "SlackDVD" .

On my system, here's the command I'd use to burn the resulting DVD ISO:

growisofs -speed=2 -dvd-compat -Z /dev/dvd=slackware-dvd.iso

If your burner is not /dev/dvd, replace the device with the one your
system uses.

I find discs burned at 2x are more reliable than ones burned at higher
speeds, but you may see completely different results depending on media
and burner type.  The -dvd-compat option is also used so that a complete
lead-out is written to the media for maximum compatibility.

Or, you can burn directly from the Slackware tree to a DVD(-/+)R(W):

growisofs \
  -Z /dev/dvd \
  -R -J -A "Slackware Install" \
  -hide-rr-moved \
  -v -d -N \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -sort isolinux/iso.sort \
  -b isolinux/isolinux.bin \
  -c isolinux/isolinux.boot \
  -m 'kde-l10n-*.tar.bz2' \
  -dvd-compat \
  -V "SlackDVD" .

Note that the source files for the KDE language translations will not be
included on these DVD images in order to keep them under the limit for
a single-layer disc.  If you are using double layer DVD media and want to
burn the complete tree to your disc, remove the -m option line from the
command.


HOW TO MAKE A SET OF BOOTABLE / INSTALLABLE CDROMS

This is a little bit more tricky.  Step one will be to split the tree into
portions that will fit on the media that you plan to burn to.  The first
disc must contain these directories:

/isolinux/
/kernels/
/slackware/

You'll need to make other /slackware/ directories on discs 2, 3, and maybe
more, moving some of the disc series from disc 1 to other discs to make
things fit.  It is also possible to split a series to make more efficient
use of the CD media.  See the README_SPLIT.TXT example and instructional
file in this directory for details about how to set that up.

The rest of the splitting up of discs is left as an exercise for the reader.

To make the first (bootable) ISO, a command like this is used within the
directory where the disc tree is.  Let's say the directory is 'd1' and you
wish to output the ISO image in /tmp:

cd d1
mkisofs -o /tmp/slackware-install-1.iso \
  -R -J -A "Slackware Install 1" \
  -hide-rr-moved \
  -v -d -N \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -sort isolinux/iso.sort \
  -b isolinux/isolinux.bin \
  -c isolinux/isolinux.boot \
  -V "SlackCD1" .

Making a non-bootable disc is similar.  Just omit a few options:

cd d2
mkisofs -o /tmp/slackware-install-2.iso \
  -R -J -A "Slackware Install 2" \
  -hide-rr-moved \
  -v -d -N \
  -V "SlackCD2" .

To burn an ISO image to CD-R(W), the cdrecord command is used.  For complete
instructions, see the man page ('man cdrecord').  On my own machine where
the burner is /dev/cdrw, disc one would be burned with the following command:

cat /tmp/slackware-install-1.iso | cdrecord -v dev=/dev/cdrw speed=10 fs=8m -tao -eject -data -

As before, it's possible to burn from the disc trees without the intermediate
step of creating iso images by omitting the -o option to mkisofs and piping
the output directly to cdrecord:

cd d1
mkisofs \
  -R -J -A "Slackware Install 1" \
  -hide-rr-moved \
  -v -d -N \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -sort isolinux/iso.sort \
  -b isolinux/isolinux.bin \
  -c isolinux/isolinux.boot \
  -V "SlackCD1" . | cdrecord -v dev=/dev/cdrw speed=10 fs=8m -tao -eject -data -

-----

NOTES:
  The isolinux/isolinux.boot file will be created on the disc;  it's not
  supposed to be in the source tree.  I mention this only because so many
  people report the "missing" isolinux/isolinux.boot file as a bug.

  The "-boot-load-size 4" is actually not large enough to hold the isolinux
  boot loader, but many BIOS implementations are broken and will *only*
  accept "4".  Evidently many newer, more correct BIOS implementations
  expect this and will continue to load the boot loader file until the
  EOF is reached.  Anyway, previous uses of larger values were correct, but
  led to the Slackware ISO not booting on some machines which contained
  broken BIOS implementations.  It is my hope that by using the incorrect
  value of 4 sectors that the ISO will boot on most (if not all) machines
  that are supposed to be able to boot from an ISO image.

  I don't know how to create a bootable Slackware ISO on operating systems
  other than Linux, but it should be easy to burn the Linux-created ISO with
  most CD burning software on any operating system.

Enjoy!

 -P.

