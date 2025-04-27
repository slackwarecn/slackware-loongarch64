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

# Keep same perms on rc.messagebus.new:
if [ -e etc/rc.d/rc.messagebus ]; then
  cp -a etc/rc.d/rc.messagebus etc/rc.d/rc.messagebus.new.incoming
  cat etc/rc.d/rc.messagebus.new > etc/rc.d/rc.messagebus.new.incoming
  mv etc/rc.d/rc.messagebus.new.incoming etc/rc.d/rc.messagebus.new
fi

#config etc/rc.d/rc.messagebus.new
# No, just install the thing.  Leaving it as .new will only lead to problems.
if [ -r etc/rc.d/rc.messagebus.new ]; then
  mv etc/rc.d/rc.messagebus.new etc/rc.d/rc.messagebus
fi

# Make sure that /etc/machine-id exists and is a file.
# Make sure /var/lib/dbus/machine-id is a symlink to /etc/machine-id.
# If you hate machine-id, you can touch /etc/no-machine-id and then we
# won't create or adjust these files in the future and you may or may not
# enjoy bugs that result from this.
if [ ! -r etc/no-machine-id ]; then
  # If etc/machine-id is a symlink, get rid of it:
  if [ -L etc/machine-id ]; then
    rm -f etc/machine-id
  fi
  # If var/lib/dbus/machine-id is a symlink, get rid of it:
  if [ -L var/lib/dbus/machine-id ]; then
    rm -f var/lib/dbus/machine-id
  fi
  # If you have both etc/machine-id and var/lib/dbus/machine-id then we will
  # keep etc/machine-id and back up var/lib/dbus/machine-id:
  if [ -r etc/machine-id -a -r var/lib/dbus/machine-id ]; then
    mv var/lib/dbus/machine-id var/lib/dbus/machine-id.backup
  fi
  # If there's a var/lib/dbus/machine-id file, and no etc/machine-id, move it:
  if [ -r var/lib/dbus/machine-id -a ! -e etc/machine-id ]; then
    mv var/lib/dbus/machine-id etc/machine-id
    chmod 444 etc/machine-id
  fi
  # If there's no etc/machine-id, fix that:
  if [ ! -r etc/machine-id ]; then
    chroot . /usr/bin/dbus-uuidgen --ensure=/etc/machine-id
    chmod 444 etc/machine-id
  fi
  # Create the var/lib/dbus/machine-id symlink:
  rm -f var/lib/dbus/machine-id
  pushd var/lib/dbus
    ln -sf /etc/machine-id .
  popd
fi
