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
if [ ! -e etc/rc.d/rc.bluetooth -o ! -x etc/rc.d/rc.bluetooth ]; then
  chmod 644 etc/rc.d/rc.bluetooth.new
else
  chmod 755 etc/rc.d/rc.bluetooth.new
fi
config etc/rc.d/rc.bluetooth.new
config etc/rc.d/rc.bluetooth.conf.new
config etc/bluetooth/asound.conf.new
config etc/bluetooth/audio.conf.new
config etc/bluetooth/hcid.conf.new
config etc/bluetooth/input.conf.new
config etc/bluetooth/network.conf.new
config etc/bluetooth/rfcomm.conf.new
config etc/bluetooth/passkeys/default.new

if [ ! -e etc/asound.conf ]; then
  ( cd etc ; ln -sf bluetooth/asound.conf . )
fi
