config() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  # If there's no config file by that name, mv it over:
  if [ ! -r $OLD ]; then
    mv $NEW $OLD
  elif [ "$(cat $OLD | md5sum)" = "$(cat $NEW | md5sum)" ]; then
    # toss the redundant copy
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

preserve_perms etc/rc.d/rc.dovecot.new

for file in etc/dovecot/*.conf.new etc/dovecot/*.ext.new etc/dovecot/conf.d/*.conf.new etc/dovecot/conf.d/*.ext.new ; do
  config $file
done

# Make sure that the dovecot user/group (UID 94, GID 94), and the
# postdrop user/group (UID 65, GID 95) exist on this system:
if ! grep -q "^dovecot:" etc/passwd ; then
  echo "dovecot:x:94:94:User for Dovecot processes:/dev/null:/bin/false" >> etc/passwd
fi
if ! grep -q "^dovenull:" etc/passwd ; then
  echo "dovenull:x:95:95:User for Dovecot login processing:/dev/null:/bin/false" >> etc/passwd
fi
if ! grep -q "^dovecot:" etc/group ; then
  echo "dovecot:x:94:" >> etc/group
fi
if ! grep -q "^dovenull:" etc/group ; then
  echo "dovenull:x:95:" >> etc/group
fi

