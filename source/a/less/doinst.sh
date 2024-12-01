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

config etc/profile.d/less.csh.new
config etc/profile.d/less.sh.new

# Link to a default lesspipe script. If you don't like this, relink to the
# other version, or install anything else you like as /usr/bin/lesspipe.sh.
# This package will leave it alone after that.
if [ ! -e usr/bin/lesspipe.sh ]; then
  ( cd usr/bin ; ln -sf lesspipe-volkerdi.sh lesspipe.sh )
fi
