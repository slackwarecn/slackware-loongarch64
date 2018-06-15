#!/bin/sh

# If the smmsp user/group don't exist, add them:
if ! grep -q "^smmsp:" etc/passwd ; then
  echo "smmsp:x:25:25:smmsp:/var/spool/clientmqueue:" >> etc/passwd
fi
if ! grep -q "^smmsp:" etc/group ; then
  echo "smmsp::25:smmsp" >> etc/group
fi

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

config etc/mail/Makefile.new
config etc/mail/access.db.new
config etc/mail/access.new
config etc/mail/aliases.db.new
config etc/mail/aliases.new
config etc/mail/domaintable.db.new
config etc/mail/domaintable.new
config etc/mail/local-host-names.new
config etc/mail/mailertable.db.new
config etc/mail/mailertable.new
config etc/mail/sendmail.cf.new
config etc/mail/statistics.new
config etc/mail/submit.cf.new
config etc/mail/trusted-users.new
config etc/mail/virtusertable.db.new
config etc/mail/virtusertable.new
# Keep same perms on rc.sendmail.new:
if [ -e etc/rc.d/rc.sendmail ]; then
  cp -a etc/rc.d/rc.sendmail etc/rc.d/rc.sendmail.new.incoming
  cat etc/rc.d/rc.sendmail.new > etc/rc.d/rc.sendmail.new.incoming
  touch -r etc/rc.d/rc.sendmail.new etc/rc.d/rc.sendmail.new.incoming
  mv etc/rc.d/rc.sendmail.new.incoming etc/rc.d/rc.sendmail.new
fi
config etc/rc.d/rc.sendmail.new

# These are shipped empty, so rm them if they weren't needed:
rm -f etc/mail/access.db.new etc/mail/access.new etc/mail/domaintable.db.new etc/mail/domaintable.new etc/mail/local-host-names.new etc/mail/mailertable.db.new etc/mail/mailertable.new etc/mail/statistics.new etc/mail/trusted-users.new etc/mail/virtusertable.db.new etc/mail/virtusertable.new
# This also shouldn't be needed later (the admin should generate a new one):
rm -f etc/mail/aliases.db.new

# Install new sendmail binary:
rm -f usr/sbin/sendmail
mv usr/sbin/sendmail.new usr/sbin/sendmail

# Make sure we have the perms right on these:
chown root:smmsp usr/sbin/sendmail
chmod 2555 usr/sbin/sendmail
chown smmsp:smmsp var/spool/clientmqueue

( cd usr/bin ; rm -rf newaliases )
( cd usr/bin ; ln -sf /usr/sbin/sendmail newaliases )
( cd usr/bin ; rm -rf mailq )
( cd usr/bin ; ln -sf /usr/sbin/sendmail mailq )
( cd usr/bin ; rm -rf hoststat )
( cd usr/bin ; ln -sf /usr/sbin/sendmail hoststat )
( cd usr/bin ; rm -rf purgestat )
( cd usr/bin ; ln -sf /usr/sbin/sendmail purgestat )
( cd usr/lib ; rm -rf sendmail )
( cd usr/lib ; ln -sf /usr/sbin/sendmail sendmail )
( cd usr/bin ; rm -rf sendmail )
( cd usr/bin ; ln -sf /usr/sbin/sendmail sendmail )

( cd usr/sbin ; rm -rf praliases )
( cd usr/sbin ; ln -sf ../bin/praliases praliases )
