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
config etc/ppp/chap-secrets.new
config etc/ppp/options.new
config etc/ppp/pap-secrets.new

config etc/radiusclient/issue.new
config etc/radiusclient/radiusclient.conf.new
config etc/radiusclient/realms.new
config etc/radiusclient/servers.new

