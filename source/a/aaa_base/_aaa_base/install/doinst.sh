# Invite the new admin to register their machine with the Linux Counter:
if [ ! -f var/spool/mail/root ]; then
 mv var/spool/mail/root.new var/spool/mail/root
else
 cat var/spool/mail/root.new >> var/spool/mail/root
 rm var/spool/mail/root.new
fi
# (Starting with Slackware 8.1) note:  These links are now replaced by
# copies of the header files that were used to compile glibc (in the
# kernel-headers package).  The version number on the kernel-headers
# package does *not* necessarily need to match the kernel in use.
#( cd usr/include ; rm -rf linux )
#( cd usr/include ; ln -sf /usr/src/linux/include/linux linux )
#( cd usr/include ; rm -rf asm )
#( cd usr/include ; ln -sf /usr/src/linux/include/asm asm )
# OK, I'd rather leave X11R6 right where it is if you're upgrading
# your box, but it's easy for the choice to get rid of /usr/X11R6
# to be made, and much harder to get 100% of the rest of the world
# to do along with it.  :-)
#
# This setup should allow the following packages to install in a
# sane fashion, and should also allow third-party video drivers to
# find X in the old places.  However, anything you've installed in
# your /usr/X11R6 directory will be moved to /usr/X11R6.bak.
# Anything you really want want to keep will need to be merged back
# by hand.
if [ ! -L usr/X11R6/bin ]; then
  if [ -d usr/X11R6 ]; then
    mv usr/X11R6 usr/X11R6.bak
  fi
fi
mkdir -p usr/X11R6
( cd usr/X11R6
  for dir in ../bin ../include ../lib ../libexec ../man ../share ; do
    rm -rf $(basename $dir)
    ln -sf $dir .
  done
)
( cd usr ; rm -rf X11 )
( cd usr ; ln -sf X11R6 X11 )
( cd usr/bin ; rm -rf X11 )
( cd usr/bin ; ln -sf . X11 )
if [ -L usr/include/X11 ]; then
  ( cd usr/include ; rm -rf X11 )
fi
# Did anything ever use this?  I don't know, but if we're keeping all
# this other garbage then it probably won't hurt:
if [ -d usr/X11R6/lib/X11 ]; then
( cd var ; rm -rf X11R6 )
( cd var ; ln -sf ../usr/X11R6/lib/X11 X11R6 )
elif [ -d usr/X11R6/lib64/X11 ]; then
( cd var ; rm -rf X11R6 )
( cd var ; ln -sf ../usr/X11R6/lib64/X11 X11R6 )
fi
# As long as we're producing clutter:
if [ -d var/X11R6 -o -L var/X11R6 ]; then
  ( cd var ; rm -rf X11 )
  ( cd var ; ln -sf X11R6 X11 )
fi
# These are rather obsolete, but...
( cd usr/man ; rm -rf cat1 )
( cd usr/man ; ln -sf /var/man/cat1 cat1 )
( cd usr/man ; rm -rf cat2 )
( cd usr/man ; ln -sf /var/man/cat2 cat2 )
( cd usr/man ; rm -rf cat3 )
( cd usr/man ; ln -sf /var/man/cat3 cat3 )
( cd usr/man ; rm -rf cat4 )
( cd usr/man ; ln -sf /var/man/cat4 cat4 )
( cd usr/man ; rm -rf cat5 )
( cd usr/man ; ln -sf /var/man/cat5 cat5 )
( cd usr/man ; rm -rf cat6 )
( cd usr/man ; ln -sf /var/man/cat6 cat6 )
( cd usr/man ; rm -rf cat7 )
( cd usr/man ; ln -sf /var/man/cat7 cat7 )
( cd usr/man ; rm -rf cat8 )
( cd usr/man ; ln -sf /var/man/cat8 cat8 )
( cd usr/man ; rm -rf cat9 )
( cd usr/man ; ln -sf /var/man/cat9 cat9 )
( cd usr/man ; rm -rf catn )
( cd usr/man ; ln -sf /var/man/catn catn )
# Other standard links:
( cd usr ; rm -rf adm )
( cd usr ; ln -sf /var/adm adm )
( cd usr ; rm -rf spool )
( cd usr ; ln -sf /var/spool spool )
( cd usr ; rm -rf tmp )
( cd usr ; ln -sf /var/tmp tmp )
( cd usr ; rm -rf dict )
( cd usr ; ln -sf share/dict dict )
# "/var/adm" is where I used to keep the Slackware package database until
# the FHS people "standardized" making it a symlink to /var/log...
( cd var ; rm -rf adm )
( cd var ; ln -sf log adm )
( cd bin ; rm -rf sh )
( cd bin ; ln -sf bash sh )
( cd var ; rm -rf mail )
( cd var ; ln -sf spool/mail mail )
( cd usr/share ; rm -rf man )
( cd usr/share ; ln -sf ../man man )
( cd usr/share ; rm -rf doc )
( cd usr/share ; ln -sf ../doc doc )
( cd usr/share ; rm -rf info )
( cd usr/share ; ln -sf ../info info )
# These seem like useless fluff.
( cd media ; rm -rf hd )
( cd media ; ln -sf hd0 hd )
( cd media ; rm -rf dvd )
( cd media ; ln -sf dvd0 dvd )
( cd media ; rm -rf zip )
( cd media ; ln -sf zip0 zip )
( cd media ; rm -rf cdrom )
( cd media ; ln -sf cdrom0 cdrom )
( cd media ; rm -rf cdrecorder )
( cd media ; ln -sf cdrecorder0 cdrecorder )
( cd media ; rm -rf floppy )
( cd media ; ln -sf floppy0 floppy )
( cd media ; rm -rf memory )
( cd media ; ln -sf memory0 memory )
