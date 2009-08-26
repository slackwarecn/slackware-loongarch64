
# X.Org will work without any xorg.conf now, so don't move anything
# into place by default.  Commenting out the block below:

## Use framebuffer by default if no xorg.conf is found:
#if [ ! -r etc/X11/xorg.conf -a -r etc/X11/xorg.conf-vesa ]; then
#  cp -a etc/X11/xorg.conf-vesa etc/X11/xorg.conf
#fi

( cd usr/lib/X11 ; rm -rf fonts )
( cd usr/lib/X11 ; ln -sf ../../share/fonts fonts )
# This setup should allow the following packages to install in a
# sane fashion, and should also allow third-party video drivers to
# find X in the old places.  However, anything you've installed in
# your /usr/X11R6 directory will be moved to /usr/X11R6.bak.
# Anything you really want want to keep will need to be merged back
# by hand.
if [ ! -L /usr/X11R6/bin ]; then
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
