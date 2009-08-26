#!/bin/sh
# Handle the incoming configuration files:
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
config etc/rc.d/rc.inet1.new
config etc/rc.d/rc.inet1.conf.new
config etc/rc.d/rc.inet2.new
config etc/rc.d/rc.ip_forward.new
config etc/hosts.new
config etc/hosts.deny.new
config etc/hosts.equiv.new
config etc/networks.new
config etc/nntpserver.new
config etc/resolv.conf.new
config etc/HOSTNAME.new
config etc/host.conf.new
config etc/hosts.allow.new
config etc/protocols.new

# OK, some of these aren't useful as examples, and have to be
# considered clutter if you've already got the file.
# So out they go.
rm -f etc/HOSTNAME.new
rm -f etc/hosts.new
rm -f etc/resolv.conf.new
rm -f etc/nntpserver.new

