if [ -x /usr/bin/update-mime-database ]; then
  chroot . /usr/bin/update-mime-database /usr/share/mime 1>/dev/null 2>/dev/null
fi

