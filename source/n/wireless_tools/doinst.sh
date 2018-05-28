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
config etc/rc.d/rc.wireless.conf.new

# This is a kludge, but it's because there's no --reference option
# on busybox's 'chmod':
if [ -e etc/rc.d/rc.wireless ]; then
  if [ -x etc/rc.d/rc.wireless ]; then
    chmod 755 etc/rc.d/rc.wireless.new
  else
    chmod 644 etc/rc.d/rc.wireless.new
  fi
fi
# Then config() it:
config etc/rc.d/rc.wireless.new

