config() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  # If there's no config file by that name, mv it over:
  if [ ! -r $OLD ]; then
    mv $NEW $OLD
  elif [ "$(cat $OLD | md5sum)" = "$(cat $NEW | md5sum)" ]; then # toss the redundant copy
    rm $NEW
  fi
  # Otherwise, we leave the .new copy for the admin to consider...
}

# Keep same perms on rc.atalk.new:
if [ -e etc/rc.d/rc.atalk ]; then
  cp -a etc/rc.d/rc.atalk etc/rc.d/rc.atalk.new.incoming
  cat etc/rc.d/rc.atalk.new > etc/rc.d/rc.atalk.new.incoming
  mv etc/rc.d/rc.atalk.new.incoming etc/rc.d/rc.atalk.new
fi

config etc/rc.d/rc.atalk.new

config etc/netatalk/AppleVolumes.default.new
config etc/netatalk/AppleVolumes.system.new
config etc/netatalk/afp_ldap.conf.new
config etc/netatalk/afpd.conf.new
config etc/netatalk/afppasswd.new
config etc/netatalk/atalkd.conf.new
config etc/netatalk/netatalk.conf.new 
config etc/netatalk/papd.conf.new
# Don't need an empty file:
rm -f etc/netatalk/afppasswd.new
