#!/bin/sh
config() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  # If there's no config file by that name, mv it over:
  if [ ! -r $OLD ]; then
    mv $NEW $OLD
  elif [ "$(cat $OLD | md5sum)" = "$(cat $NEW | md5sum)" ]; then # toss the redundant copy
    rm $NEW
  fi
  # Otherwise, we leave the .new copy for the admin to consider...
}
# Move old config file if there's nothing in the way:
if [ -r usr/lib/man.conf -a ! -r etc/man.conf ]; then
  mv usr/lib/man.conf etc/man.conf
fi
# Install new config file if none exists:
config etc/man.conf.new

