if [ -x /usr/bin/update-desktop-database ]; then
  chroot . /usr/bin/update-desktop-database /usr/share/applications 1> /dev/null 2>/dev/null
fi

