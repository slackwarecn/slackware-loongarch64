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
config var/log/uucp/DEBUG.new
config var/log/uucp/Debug.new
config var/log/uucp/LOGFILE.new
config var/log/uucp/Log.new
config var/log/uucp/SYSLOG.new
config var/log/uucp/Stats.new
rm -f var/log/uucp/DEBUG.new var/log/uucp/Debug.new var/log/uucp/LOGFILE.new var/log/uucp/Log.new var/log/uucp/SYSLOG.new var/log/uucp/Stats.new
