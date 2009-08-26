sbootmgr.dsk  This nifty little tool allows selecting various devices to boot
              from a menu, and even allows booting a CD-ROM in machines where
              the BIOS doesn't support it (or it's supposed to support it, but
              it just doesn't work).  If you have trouble booting the
              Slackware CD-ROM, you might try writing this image to a floppy,
              booting it, and then selecting your CD-ROM drive as the boot
              device.

              The SBM installer is available as a Slackware package (called
              "btmgr") in the extra/ packages collection.

----------------------------
Generic floppy image creation info:

To create a floppy disk from one of these images, use the RAWRITE command on
DOS or Windows.  For example, to make the first rootdisk image (install.1),
you'd put a formatted 1.44MB floppy in your floppy drive, and then run this
command:

C:\> RAWRITE INSTALL.1 A:

There are several versions of RAWRITE provided to handle most versions of DOS
and Windows.  If one version doesn't seem to work, try another.

To make the floppy images under Linux, use the "cat" command to send them to
the floppy device.  This command will make the first install disk:

cat install.1 > /dev/fd0

