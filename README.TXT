
Welcome to Slackware 13.0!  (64-bit x86_64 edition)

Slackware 13.0 is a complete distribution of the Linux operating system.

Here are some versions of major components of Slackware 13.0:

- Linux kernel           2.6.29.6
- C compiler             gcc-4.3.3
- Binutils               2.18.50.0.9
- GNU C Library          glibc-2.9
- X Window System        Updated (but not "bleeding edge") packages
                         from X.Org
- KDE                    4.2.4
- Xfce                   4.6.1

For installation instructions, see the file 'Slackware-HOWTO'.

For important hints about this release, see the file 'CHANGES_AND_HINTS.TXT'.

These are some of the important files and directories found on the Slackware
FTP site:

  ftp://ftp.slackware.com/pub/slackware/slackware-13.0/

There is also a newer (and faster) primary FTP site for Slackware here:

  ftp://slackware.osuosl.org/pub/slackware/slackware-13.0/

Thanks to cwo.com for continuing to help us with hosting for our web site
and ftp.slackware.com, and to the OSU Open Source Lab for hosting our
archives at slackware.osuosl.org.

If you're reading this on a CD-ROM, these directories will probably be
split across several discs.

.
|-- ANNOUNCE.13_0        Announcement for Slackware 13.0.
|-- BOOTING.TXT          Tips for troubleshooting boot problems.
|-- CHANGES_AND_HINTS.TXT  A summary of major changes from Slackware 12.2
|                        to 13.0 and common pitfalls.  Slackware 13.0
|                        x86_64 (Slackware64) is the first release to the
|                        64-bit x86_64 architecture, but the information
|                        contained in this file is still useful.
|-- CHECKSUMS.md5        MD5 format file checksums.
|-- COPYING              The GNU Public License, version 2.
|-- COPYING3             The GNU Public License, version 3.
|-- COPYRIGHT.TXT        Slackware copyright and trademark information.
|-- CRYPTO_NOTICE.TXT    Legal information about encryption in Slackware.
|-- ChangeLog.txt        Log of system changes.
|-- FILELIST.TXT         List of files on the Slackware FTP site.
|-- GPG-KEY              The GnuPG key used to verify Slackware packages.
|-- PACKAGES.TXT         A detailed list of the core Slackware packages.
|-- README.initrd        Information about building an initrd for use with
|                        a generic Linux kernel.
|-- README_CRYPT.TXT     Information about installing Slackware with
|                        encrypted LVM.
|-- README_LVM.TXT       Information about how to install Slackware onto LVM
|                        (including the /, if you want).
|-- README_RAID.TXT      Information about installing Slackware using the
|                        kernel's Software RAID (md) levels.
|-- SPEAKUP_DOCS.TXT     Documentation for the Speakup speech synth software.
|-- SPEAK_INSTALL.TXT    How to install with Speakup speech synthesis.
|
|-- Slackware-HOWTO      Instructions for installing Slackware from CD.
|                        If you're new to Slackware, start with this.
|
|-- extra/               Extra packages for Slackware like:
|   |                    aspell-word-lists, bash-completion, bittorrent,
|   |                    brltty, the Java(TM) JDK, kde3-compat, mpg123,
|   |                    mplayerplug-in, partitionmanager (GUI partitioning
|   |                    tool for KDE4), slacktrack, tightvnc, wicd and
|   |                    xf86-video-intel-alternate (alternate video drivers
|   |                    that may help cure instabilities on some Intel
|   |                    chipsets), yasm assembler.
|   |
|   `-- source/          Source code for the extra packages.
|
|-- isolinux/            The ISOLINUX loader and initrd.img used to install
|   |                    Slackware from installation media or the network.
|   |                    Also found here is a README.TXT file describing how
|   |                    to create a Slackware installation ISO image and
|   |                    burn it to CD-R or DVD-(+)R.
|   |
|   |-- README.TXT       How to burn a Bootable Slackware disc.
|   |
|   `-- initrd.img       Installation initrd (can also be loaded with Loadlin)
|
|-- kernels/             Precompiled Linux 2.6.29.6 kernel images.
|   |
|   |-- huge.s           The default standard install kernel for Slackware.
|   |                    This supports pretty much everything in the
|   |                    2.6.29.6 kernel.  This kernel requires an x86_64
|   |                    (also known as AMD64, EM64T, or Intel 64) capable
|   |                    64-bit CPU.
|   |
|   `-- speakup.s        A huge.s kernel patched to support speakup
|                        speech output through various hardware and 
|                        software speech synthesizers.
|
|-- pasture/             Used to store packages that have been removed from
|   |                    Slackware, but are useful enough to keep around.
|   |                    This is currently empty in x86_64 Slackware.
|   |
|   `-- source/          Source code directory for the pasture packages.
|                        This directory is also currently empty.
|
|-- slackware/           This directory contains the core software packages
|   |                    for Slackware 13.0.
|   |
|   |-- a/               The A (base) package series.
|   |-- ap/              The AP (applications) package series.
|   |-- d/               The D (development) package series.
|   |-- e/               The E (GNU Emacs) package series.
|   |-- f/               The F (FAQ/Documentation) package series.
|   |-- k/               The K (kernel source) package series.
|   |-- kde/             The KDE package series.
|   |-- kdei/            The KDE internationalization package series.
|   |-- l/               The L (libraries) package series.
|   |-- n/               The N (networking) package series.
|   |-- t/               The T (TeX) package series.
|   |-- tcl/             The TCL (Tcl/Tk and related) package series.
|   |-- x/               The X (X Window System) package series.
|   |-- xap/             The XAP (X applications) package series.
|   `-- y/               The Y (BSD games) package series.
|
|-- source/              This directory contains source code for the core
|   |                    software packages in Slackware.
|   |
|   |-- a/               Source for the A (base) series.
|   |-- ap/              Source for the AP (applications) series.
|   |-- d/               Source for the D (development) series.
|   |-- e/               Source for the E (GNU Emacs) series.
|   |-- f/               slack-desc files for the F (FAQ) series.
|   |-- installer/       Source for utilities used in the installer.
|   |-- k/               Source for the K (kernel source) series.
|   |-- kde/             Source for the KDE series.
|   |-- kdei/            Source for the KDEI series.
|   |-- l/               Source for the L (libraries) series.
|   |-- n/               Source for the N (networking) series.
|   |-- t/               Source for the T (TeX) series.
|   |-- tcl/             Source for the TCL (Tcl/Tk and related) series.
|   |-- x/               Source for the X (X Window System) series.
|   |-- xap/             Source for the XAP (X applications) series.
|   `-- y/               Source for the Y (BSD games) series.
|
|-- testing/             This directory contains packages being tested
|   |                    for possible use in future versions of Slackware.
|   |                    You'll find bash-4.0 and linux kernel 2.6.30.5
|   |                    packages here. We considered it a little early to
|   |                    replace the versions in the main tree but these
|   |                    may be useful if your hardware requires a newer
|   |                    kernel or you want some of the features of the
|   |                    next generation bash.  These packages should not
|   |                    be considered supported or necessarily secure, but
|   |                    may still useful.
|   |
|   `--- source/         This directory contains source code for the 
|                        packages in testing.
|
`-- usb-and-pxe-installers  These are alternate installers useful
    |                       for large-scale Linux deployment or if
    |                       your machine can boot PXE and/or USB but
    |                       not an optical disc.  For PXE, the initrd.img
    |                       file in isolinux/ is also required.
    |
    |-- README_PXE.TXT
    |-- README_USB.TXT
    |-- pxelinux.cfg_default
    `-- usbboot.img       The Slackware installer for bootable USB flash.


If you like Slackware, please consider supporting the project by becoming
a Slackware subscriber.  The announcement (ANNOUNCE_13.0) in this directory
has information about ordering or subscribing to the Slackware CD-ROM or
DVD releases.  Note that at this time the x86_64 release is only available
as part of the DVD -- if there's interest in a CD-ROM version, let us know.
You can find out about ordering Slackware on media, or read more about it
(and check out other Slackware-related items for sale) by visiting the
Slackware store.  We also gratefully accept financial contributions under
the "All" section of the store site menu.

Thanks for your consideration and help!

    http://store.slackware.com


Enjoy!

Patrick Volkerding
volkerdi@slackware.com

