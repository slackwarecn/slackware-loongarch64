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
config etc/updatedb.conf.new

if ! grep ^slocate: etc/group 1> /dev/null 2> /dev/null ; then
  echo "slocate::21:" >> etc/group
  chown root.slocate usr/bin/mlocate
  chown root.slocate var/lib/mlocate
fi

if [ ! -r var/lib/mlocate/mlocate.db ]; then
  touch var/lib/mlocate/mlocate.db
  chown root:slocate var/lib/mlocate/mlocate.db
  chmod 640 var/lib/mlocate/mlocate.db
fi

