# Ensure sane /tmp permissions which may have been set incorrectly due
# to a packaging problem caused by a DESTDIR bug in libgpod-0.8.0.
# Eventually, it will be safe to remove this, but the package contained
# a wrong permissions /tmp for less than a day, only in -current.

if grep -wq tmp/ var/log/packages/libgpod-* ; then
  chmod 1777 tmp
fi

