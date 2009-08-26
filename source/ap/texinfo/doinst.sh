# If no dir file exists, we'll assume it's a fresh installation and create one
# Otherwise, we'll throw out the new copy to preserve what's already installed
if [ -e usr/info/dir ]; then
  # If there is no topmost node, this dir file is broken, so replace it:
  if ! grep -q "Node: Top" usr/info/dir ; then
    mv usr/info/dir.new usr/info/dir
  fi
else
  mv usr/info/dir.new usr/info/dir
fi

