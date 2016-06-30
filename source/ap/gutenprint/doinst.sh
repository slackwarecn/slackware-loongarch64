# Only attempt this on a running system, otherwise we'll catch it
# in post-install.
if [ -x /usr/sbin/cups-genppdupdate ]; then
  chroot . /usr/sbin/cups-genppdupdate 1> /dev/null 2> /dev/null
fi
