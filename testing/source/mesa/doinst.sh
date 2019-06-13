#!/bin/sh
config() {
  NEW="$1"
  OLD="`dirname $NEW`/`basename $NEW .new`"
  # If there's no config file by that name, mv it over:
  if [ ! -r $OLD ]; then
    mv $NEW $OLD
  elif [ "`cat $OLD | md5sum`" = "`cat $NEW | md5sum`" ]; then # toss the redundant copy
    rm $NEW
  fi
  # Otherwise, we leave the .new copy for the admin to consider...
}
# Don't mess with /etc/drirc. Mesa now installs the defaults as
# /usr/share/drirc.d/00-mesa-defaults.conf. We won't protect that
# as a .new file as it shouldn't be modified. Create /etc/drirc if
# you need local overrides.
#config etc/drirc.new
