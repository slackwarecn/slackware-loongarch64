# Compile /etc/file/magic.mgc:
chroot . /usr/bin/file --compile 1> /dev/null 2> /dev/null
if [ -r magic.mgc ]; then
  mv magic.mgc etc/file
fi
