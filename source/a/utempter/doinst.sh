if ! grep "^utmp:" etc/group 1> /dev/null 2> /dev/null ; then
  if ! grep ":22:" etc/group 1> /dev/null 2> /dev/null ; then
    # we'll be adding this in the etc package anyway.
    echo "utmp::22:" >> etc/group
    # This should be able to handle itself...
    #chown root:utmp usr/sbin/utempter
  fi
fi
chown root:utmp var/run/utmp var/log/wtmp
chmod 664 var/run/utmp var/log/wtmp
