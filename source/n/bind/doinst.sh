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

# Keep same perms on rc.bind.new:
if [ -e etc/rc.d/rc.bind ]; then
  cp -a etc/rc.d/rc.bind etc/rc.d/rc.bind.new.incoming
  cat etc/rc.d/rc.bind.new > etc/rc.d/rc.bind.new.incoming
  mv etc/rc.d/rc.bind.new.incoming etc/rc.d/rc.bind.new
fi

config etc/default/named.new
config etc/named.conf.new
config etc/rc.d/rc.bind.new

# Add a /var/named if it doesn't exist:
if [ ! -d var/named ]; then
  mkdir -p var/named
  chmod 755 var/named
fi

# Generate /etc/rndc.key if there's none there,
# and there's also no /etc/rndc.conf (the other
# way to set this up).
if [ ! -r etc/rndc.key -a ! -r /etc/rndc.conf ]; then
  chroot . /sbin/ldconfig
  chroot . /usr/sbin/rndc-confgen -a 2> /dev/null
  chroot . /bin/chown named:named /etc/rndc.key 2> /dev/null
fi
