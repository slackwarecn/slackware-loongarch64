# Let's attempt to activate these libraries as they might be needed by various
# install scripts early on. We used to package symlinks in the normal way, and
# it's possible that would be fine too, but there must(?) have been a reason
# that we quit doing that...
if [ -x sbin/ldconfig ]; then
  sbin/ldconfig -r . 2> /dev/null
fi
