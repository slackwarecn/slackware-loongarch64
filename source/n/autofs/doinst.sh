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

# Keep same perms on rc.autofs.new:
if [ -e etc/rc.d/rc.autofs ]; then
  cp -a etc/rc.d/rc.autofs etc/rc.d/rc.autofs.new.incoming
  cat etc/rc.d/rc.autofs.new > etc/rc.d/rc.autofs.new.incoming
  mv etc/rc.d/rc.autofs.new.incoming etc/rc.d/rc.autofs.new
fi

config etc/auto.master.new
config etc/auto.misc.new
config etc/autofs_ldap_auth.conf.new
config etc/default/autofs.new

config etc/rc.d/rc.autofs.new

