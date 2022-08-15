if [ -x usr/bin/update-gtk-immodules ]; then
  chroot . /usr/bin/update-gtk-immodules --verbose 1>/dev/null
fi

