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

# Keep same perms on rc.atalk.new:
if [ -e etc/rc.d/rc.atalk ]; then
  cp -a etc/rc.d/rc.atalk etc/rc.d/rc.atalk.new.incoming
  cat etc/rc.d/rc.atalk.new > etc/rc.d/rc.atalk.new.incoming
  mv etc/rc.d/rc.atalk.new.incoming etc/rc.d/rc.atalk.new
fi

config etc/rc.d/rc.atalk.new

config etc/netatalk/afp.conf.new
config etc/netatalk/dbus-session.conf.new
config etc/netatalk/extmap.conf.new

if [ -r etc/pam.d/netatalk.new ]; then
  config etc/pam.d/netatalk.new
fi
