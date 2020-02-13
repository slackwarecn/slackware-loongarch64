config() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  # If there's no config file by that name, mv it over:
  if [ ! -r $OLD ]; then
    mv $NEW $OLD
  elif [ "$(cat $OLD | md5sum)" = "$(cat $NEW | md5sum)" ]; then
    # toss the redundant copy
    rm $NEW
  fi
  # Otherwise, we leave the .new copy for the admin to consider...
}

# Keep same perms on rc.serial.new:
if [ -e etc/rc.d/rc.serial ]; then
  cp -a etc/rc.d/rc.serial etc/rc.d/rc.serial.new.incoming
  cat etc/rc.d/rc.serial.new > etc/rc.d/rc.serial.new.incoming
  mv etc/rc.d/rc.serial.new.incoming etc/rc.d/rc.serial.new
fi

config etc/rc.d/rc.serial.new
config etc/rc.d/rc.setterm.new
config etc/serial.conf.new

if [ -r etc/default/su.new ]; then
  config etc/default/su.new
fi
