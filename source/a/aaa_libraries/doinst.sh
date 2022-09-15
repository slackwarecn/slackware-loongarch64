# Let's attempt to activate these libraries as they might be needed by various
# install scripts early on. We used to package symlinks in the normal way, and
# it's possible that would be fine too, but there must(?) have been a reason
# that we quit doing that...
cat var/lib/pkgtools/packages/aaa_libraries* 2> /dev/null | grep -e "^lib" -e "/lib" | grep -v "/$" | while read file ; do
  if [ -r "$file" ]; then
    ldconfig -l "$file" 1> /dev/null 2> /dev/null
  fi
done
