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
  OLD="$(dirname ${NEW})/$(basename ${NEW} .new)"
  if [ -e ${OLD} ]; then
    cp -a ${OLD} ${NEW}.incoming
    cat ${NEW} > ${NEW}.incoming
    mv ${NEW}.incoming ${NEW}
  fi
  config ${NEW}
}

config etc/samba/lmhosts.new
preserve_perms etc/rc.d/rc.samba.new

# Commented out 2014-09-15 just in case we do need to change this.
## This won't be needed.  The point here is to preserve the permissions of the existing
## file, if there is one.  I don't see major new development happening in rc.samba...  ;-)
#rm -f etc/rc.d/rc.samba.new

# Since /etc/samba/private/ has moved to /var/lib/samba/private, migrate any
# important files if possible:
if [ -d etc/samba/private -a -d var/lib/samba/private ]; then
  for file in etc/samba/private/* ; do
    if [ -r "$file" -a ! -r "var/lib/samba/private/$(basename $file)" ]; then
      mv "$file" var/lib/samba/private
    fi
  done
  # Might as well try to eliminate this directory, since it should be empty:
  rmdir etc/samba/private 1> /dev/null 2> /dev/null
fi
