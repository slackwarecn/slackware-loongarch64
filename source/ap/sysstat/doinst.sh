
# Since /etc/sysstat/sysstat used to be the init script and now it is
# a config file, if we find an init script here, we have to move it
# out of the way:
if grep -wq "sadc was successfully launched" etc/sysstat/sysstat 1> /dev/null 2> /dev/null ; then
  mv etc/sysstat/sysstat etc/sysstat/sysstat.obsolete.use.etc.rc.d.rc.sysstat
fi

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

config etc/sysstat/sysstat.new

# Keep same perms on rc.sysstat.new:
if [ -e etc/rc.d/rc.sysstat ]; then
  cp -a etc/rc.d/rc.sysstat etc/rc.d/rc.sysstat.new.incoming
  cat etc/rc.d/rc.sysstat.new > etc/rc.d/rc.sysstat.new.incoming
  mv etc/rc.d/rc.sysstat.new.incoming etc/rc.d/rc.sysstat.new
fi

# There's no reason for a user to edit rc.sysstat, so overwrite it:
if [ -r etc/rc.d/rc.sysstat.new ]; then
  mv etc/rc.d/rc.sysstat.new etc/rc.d/rc.sysstat
fi

