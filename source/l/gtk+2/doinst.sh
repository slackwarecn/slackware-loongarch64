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
if [ -d etc/gtk-2.0/$(uname -m)-slackware-linux ]; then
  config etc/gtk-2.0/$(uname -m)-slackware-linux/im-multipress.conf.new
elif [ -d etc/gtk-2.0/i486-slackware-linux ]; then
  config etc/gtk-2.0/i486-slackware-linux/im-multipress.conf.new
elif [ -d etc/gtk-2.0/*-slackware-linux ]; then
  config etc/gtk-2.0/*-slackware-linux/im-multipress.conf.new
fi

# Since the use of icon caching is optional, and has to be kept in sync
# somehow (like a "registry" through a cron job, or whatever, I tend to
# think the user should be the one to choose if they really want to set
# this up or not:
#
# Example:
#for dir in /usr/share/icons/* ; do
#  if [ -d $dir ]; then
#    /usr/bin/gtk-update-icon-cache -f -t $dir 1> /dev/null 2> /dev/null
#  fi
#done
mkdir -p etc/gtk-2.0

chroot . rm -f /usr/share/icons/*/icon-theme.cache 1> /dev/null 2> /dev/null

# Run this if we are on an installed system.  Otherwise it will be
# handled on first boot.
if [ -x /usr/bin/update-gtk-immodules-2.0 ]; then
  /usr/bin/update-gtk-immodules
fi

