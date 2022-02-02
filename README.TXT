Welcome to Slackware 15.0!  (64-bit x86_64 edition)

Slackware 15.0 is a complete distribution of the Linux operating system.

Here are some versions of major components of Slackware 15.0:

- Linux kernel           5.15.19
- GCC compiler           11.2.0
- LLVM compiler          13.0.0
- Rust compiler          1.58.1
- Binutils               2.37
- GNU C Library          2.33
- KDE Plasma             5.23.5
- Xfce                   4.16

For installation instructions, see the file 'Slackware-HOWTO'.

For important hints about this release, see the file 'CHANGES_AND_HINTS.TXT'.

These are some of the important files and directories found on the Slackware
FTP site:

  ftp://ftp.slackware.com/pub/slackware/slackware64-15.0/

Thanks to cwo.com for continuing to help us with hosting for our web site,
and to the OSU Open Source Lab for hosting our archives at ftp.slackware.com
(aka ftp.osuosl.org).

If you're reading this on a CD-ROM, these directories will probably be
split across several discs.

.
|-- ANNOUNCE.15.0        Announcement for Slackware 15.0.
|-- CHANGES_AND_HINTS.TXT  A summary of major changes from Slackware 14.2
|                        to 15.0 and common pitfalls.
|-- CHECKSUMS.md5        MD5 format file checksums.
|-- COPYING              The GNU Public License, version 2.
|-- COPYING3             The GNU Public License, version 3.
|-- COPYRIGHT.TXT        Slackware copyright and trademark information.
|-- CRYPTO_NOTICE.TXT    Legal information about encryption in Slackware.
|-- ChangeLog.txt        Log of system changes.
|-- EFI/                 Boot files for UEFI systems.
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
|-- README_UEFI.TXT      Instructions for installing on UEFI machines.
|-- SPEAKUP_DOCS.TXT     Documentation for the Speakup speech synth software.
|-- SPEAK_INSTALL.TXT    How to install with Speakup speech synthesis.
|
|-- Slackware-HOWTO      Instructions for installing Slackware from CD.
|                        If you're new to Slackware, start with this.
|-- UPGRADE.TXT          How to upgrade from Slackware 14.2 to Slackware 15.0.
|
|-- extra/               Extra packages for Slackware like:
|   |                    aspell-word-lists, bash-completion, bittornado,
|   |                    brltty, fltk, getty-ps, php80, php81, rust (for
|   |                    Mozilla), sendmail, tigervnc, xf86-video-fbdev,
|   |                    xf86-video-nouveau-blacklist, xfractint, and xv.
|   |                    Scripts are also included to repackage some
|   |                    non-redistributable binaries into Slackware packages:
|   |                    google-chrome and java.
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
|-- kernels/             Precompiled Linux 5.15.19 kernel images.
|   |
|   `-- huge.s           The default standard install kernel for Slackware.
|                        This supports pretty much everything in the
|                        5.15.19 kernel, and includes support for Speakup.
|                        This kernel requires an x86_64 (also known as AMD64,
|                        EM64T, or Intel 64) capable 64-bit CPU.
|    
|-- slackware64/         This directory contains the core software packages
|   |                    for Slackware 15.0.
|   |
|   |-- a/               The A (base) package series.
|   |-- ap/              The AP (applications) package series.
|   |-- d/               The D (development) package series.
|   |-- e/               The E (GNU Emacs) package series.
|   |-- f/               The F (FAQ/Documentation) package series.
|   |-- k/               The K (kernel source) package series.
|   |-- kde/             The KDE Plasma package series.
|   |-- l/               The L (libraries) package series.
|   |-- n/               The N (networking) package series.
|   |-- t/               The T (TeX) package series.
|   |-- tcl/             The TCL (Tcl/Tk and related) package series.
|   |-- x/               The X (X Window System) package series.
|   |-- xap/             The XAP (X applications) package series.
|   |-- xfce/            The XFCE (Xfce desktop) package series.
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
|   |-- l/               Source for the L (libraries) series.
|   |-- n/               Source for the N (networking) series.
|   |-- t/               Source for the T (TeX) series.
|   |-- tcl/             Source for the TCL (Tcl/Tk and related) series.
|   |-- x/               Source for the X (X Window System) series.
|   |-- xap/             Source for the XAP (X applications) series.
|   |-- xfce/            Source for the XFCE (Xfce desktop) series.
|   `-- y/               Source for the Y (BSD games) series.
|
|-- testing/             This directory contains packages being tested
|   |                    for possible use in future versions of Slackware.
|   |                    For this release, it contains sample kernel
|   |                    configuration files for Linux 5.16.5.
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
    `-- usbimg2disk.sh    Script to make a partitioned USB flash installer
                          from usbboot.img.

Slackware relies on user contributions for funding. If you'd like to help,
visit one of these links:

https://www.patreon.com/slackwarelinux
https://paypal.me/volkerdi

Contibutions are not tax deductible. Thanks for your support in any amount!

Enjoy!

Patrick Volkerding
volkerdi@slackware.com
