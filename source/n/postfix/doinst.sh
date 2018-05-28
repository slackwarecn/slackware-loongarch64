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

# Make sure that the postfix user (UID 91, GID 91), and the
# postdrop group (GID 92) exist on this system:
if ! grep -q "^postfix:" etc/passwd ; then
  echo "postfix:x:91:91:User for Postfix MTA:/dev/null:/bin/false" >> etc/passwd
fi
if ! grep -q "^postfix:" etc/group ; then
  echo "postfix:x:91:" >> etc/group
fi
if ! grep -q "^postdrop:" etc/group ; then
  echo "postdrop:x:92:" >> etc/group
fi

find etc/postfix -type f -name '*.new' | while read new ; do
  config $new
done
preserve_perms etc/rc.d/rc.postfix.new
config etc/aliases.new

# Don't keep aliases.new. If it exists, the user already defined aliases.
rm -f etc/aliases.new

# No reason to keep these: upgrade-configuration will take care of merging
# changes needed to the existing files
rm -f etc/postfix/main.cf.new etc/postfix/master.cf.new

# This is for backward compatibility with the old Sendmail package; some
# software might still expect to find the /usr/lib/sendmail link.
if [ ! -d usr/lib ]; then
mkdir -p usr/lib
( cd usr/lib ; rm -f sendmail )
( cd usr/lib ; ln -s /usr/sbin/sendmail sendmail)
fi

## COMMENTED OUT
## (The Slackware package should ship with correct permissions)
##
## This will set the permissions on all postfix files correctly
#if [ -x usr/sbin/postfix ]; then
#  chroot . /usr/sbin/postfix set-permissions
#fi

# The upgrade-configuration command will add any necessary new settings to
# existing config files (/etc/postfix/{main,master}.cf).  It won't hurt
# anything on a new install.
if [ -x usr/sbin/postfix ]; then
  chroot . /usr/sbin/postfix upgrade-configuration
fi

# Process /etc/aliases into a database:
if [ -x usr/bin/newaliases ]; then
  chroot . /usr/bin/newaliases
fi
