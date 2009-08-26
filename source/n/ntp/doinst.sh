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

config etc/ntp.conf.new
config etc/ntp/ntp.keys.new
if [ -r etc/rc.d/rc.ntpd -a -r etc/rc.d/rc.ntpd.new ]; then
  chmod --reference=etc/rc.d/rc.ntpd etc/rc.d/rc.ntpd.new
fi
config etc/rc.d/rc.ntpd.new
