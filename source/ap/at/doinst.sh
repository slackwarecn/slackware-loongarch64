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
config etc/at.deny.new
if [ ! -r var/spool/atjobs/.SEQ ]; then
  touch var/spool/atjobs/.SEQ
  chmod 660 var/spool/atjobs/.SEQ
  chown daemon.daemon var/spool/atjobs/.SEQ
fi
( cd usr/bin ; rm -rf atq )
( cd usr/bin ; ln -sf at atq )
( cd usr/bin ; rm -rf atrm )
( cd usr/bin ; ln -sf at atrm )
( cd usr/man/man1 ; rm -rf atq.1.gz )
( cd usr/man/man1 ; ln -sf at.1.gz atq.1.gz )
( cd usr/man/man1 ; rm -rf atrm.1.gz )
( cd usr/man/man1 ; ln -sf at.1.gz atrm.1.gz )
( cd usr/man/man1 ; rm -rf batch.1.gz )
( cd usr/man/man1 ; ln -sf at.1.gz batch.1.gz )
( cd usr/man/man5 ; rm -rf at_deny.5.gz )
( cd usr/man/man5 ; ln -sf at_allow.5.gz at_deny.5.gz )
