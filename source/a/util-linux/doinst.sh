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

# Keep same perms on rc.serial.new:
if [ -e etc/rc.d/rc.serial ]; then
  cp -a etc/rc.d/rc.serial etc/rc.d/rc.serial.new.incoming
  cat etc/rc.d/rc.serial.new > etc/rc.d/rc.serial.new.incoming
  mv etc/rc.d/rc.serial.new.incoming etc/rc.d/rc.serial.new
fi

config etc/rc.d/rc.serial.new
config etc/rc.d/rc.setterm.new
config etc/serial.conf.new

for configfile in chfn.new chsh.new login.new remote.new runuser.new runuser-l.new su.new su-l.new ; do
  if [ -r etc/pam.d/$configfile ]; then
    config etc/pam.d/$configfile
  fi
done

if [ -r etc/default/su.new ]; then
  config etc/default/su.new
fi

# Since libmount has dropped all support for an /etc/mtab file, if we find that
# we'll need to replace it with a symlink to /proc/mounts:
if [ ! -L etc/mtab ]; then
  rm -f etc/mtab
  ( cd etc ; ln -sf /proc/mounts mtab )
fi

