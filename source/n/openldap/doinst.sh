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
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  if [ -e $OLD ]; then
    cp -a $OLD ${NEW}.incoming
    cat $NEW > ${NEW}.incoming
    mv ${NEW}.incoming $NEW
  fi
  config $NEW
}

if ! grep -q "^ldap:" etc/passwd ; then
  echo "ldap:x:330:330:OpenLDAP server:/var/lib/openldap:/bin/false" >> etc/passwd
fi
if ! grep -q "^ldap:" etc/group ; then
  echo "ldap:x:330:" >> etc/group
fi
if ! grep -q "^ldap:" etc/shadow ; then
  echo "ldap:*:9797:0:::::" >> etc/shadow
fi

preserve_perms etc/rc.d/rc.openldap.new
config etc/default/slapd.new
config etc/openldap/ldap.conf.new
config etc/openldap/slapd.conf.new
config etc/openldap/slapd.ldif.new
