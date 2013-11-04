# Try to run these.  If they fail, no biggie.
chroot . /usr/bin/update-desktop-database -q usr/share/applications 1> /dev/null 2> /dev/null
chroot . /usr/bin/glib-compile-schemas /usr/share/glib-2.0/schemas/ 1> /dev/null 2> /dev/null

