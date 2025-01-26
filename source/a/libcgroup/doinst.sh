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

preserve_perms() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  if [ -e $OLD ]; then
    cp -a $OLD ${NEW}.incoming
    cat $NEW > ${NEW}.incoming
    mv ${NEW}.incoming $NEW
  fi
  config $NEW
}

# preserve_perms() the rc scripts:
preserve_perms etc/rc.d/rc.cgconfig.new
preserve_perms etc/rc.d/rc.cgred.new

# config() the other configuration files:
config etc/cgconfig.conf.new
config etc/cgred.conf.new
config etc/cgrules.conf.new
config etc/cgsnapshot_allowlist.conf.new
config etc/cgsnapshot_denylist.conf.new
config etc/default/cgroups.new
