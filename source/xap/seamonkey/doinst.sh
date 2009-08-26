# If there's no mozilla here, then take over:
if [ ! -r usr/bin/mozilla ]; then
  ( cd usr/bin ; ln -sf seamonkey mozilla )
fi
# Hopefully this won't break everything.  ;-)
if ! grep /usr/lib/seamonkey etc/ld.so.conf 1> /dev/null 2> /dev/null ; then
  echo "/usr/lib/seamonkey" >> etc/ld.so.conf
fi
if [ -x /sbin/ldconfig ]; then
  /sbin/ldconfig 2> /dev/null
fi
