#!/bin/sh

config() {
  for infile in $1; do
    NEW="$infile"
    OLD="$(dirname $NEW)/$(basename $NEW .new)"
    # If there's no config file by that name, mv it over:
    if [ ! -r $OLD ]; then
      mv $NEW $OLD
    elif [ "$(cat $OLD | md5sum)" = "$(cat $NEW | md5sum)" ]; then
      # toss the redundant copy
      rm $NEW
    fi
    # Otherwise, we leave the .new copy for the admin to consider...
  done
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

preserve_perms etc/rc.d/rc.atd.new
config etc/default/atd.new
config etc/at.deny.new

if [ ! -r var/spool/atjobs/.SEQ ]; then
  touch var/spool/atjobs/.SEQ
  chmod 660 var/spool/atjobs/.SEQ
  chown daemon.daemon var/spool/atjobs/.SEQ
fi
