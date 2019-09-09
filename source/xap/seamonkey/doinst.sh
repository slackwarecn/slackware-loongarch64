# Removing /usr/lib/seamonkey from ld.so.conf. That was a hack that we did
# long ago before a standalone mozilla-nss package was shipped.
# Hopefully this won't break everything.  ;-)
( cd etc
  cat ld.so.conf | grep -v /usr/lib/seamonkey > ld.so.conf.new
  mv ld.so.conf.new ld.so.conf
)
if [ -x /sbin/ldconfig ]; then
  /sbin/ldconfig 2> /dev/null
fi
