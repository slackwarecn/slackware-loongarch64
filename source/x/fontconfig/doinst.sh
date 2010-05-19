# Update the X font indexes:
if [ -x /usr/bin/fc-cache ]; then
  /usr/bin/fc-cache -f
fi
# else we'll catch it later with setup.fontconfig :-)
# make links:

