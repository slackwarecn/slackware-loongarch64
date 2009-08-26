
# If there's no vi link, take over:
if [ ! -r usr/bin/vi ]; then
  ( cd usr/bin ; ln -sf vim vi )
fi
