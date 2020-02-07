#!/bin/bash
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
config etc/screenrc.new
config etc/skel/.screenrc.new
if [ -r etc/pam.d/screen.new ]; then
  config etc/pam.d/screen.new
fi
# This is probably safer than leaving the hidden .new file...  maybe?
rm -f etc/skel/.screenrc.new
