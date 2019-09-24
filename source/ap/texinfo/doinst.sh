# If no dir file exists, we'll assume it's a fresh installation and create one
# Otherwise, we'll throw out the new copy to preserve what's already installed.
# To update your own /usr/info/dir, see: man update-info-dir
if [ -e usr/info/dir ]; then
  # If there is no topmost node, this dir file is broken, so replace it:
  if ! grep -q "Node: Top" usr/info/dir ; then
    mv usr/info/dir.new usr/info/dir
  fi
else
  mv usr/info/dir.new usr/info/dir
fi
# If these are the same, then remove usr/info/dir.new:
if [ -r usr/info/dir -a -r usr/info/dir.new ]; then
  if diff usr/info/dir usr/info/dir.new 1> /dev/null 2> /dev/null ; then
    rm usr/info/dir.new
  fi
fi
