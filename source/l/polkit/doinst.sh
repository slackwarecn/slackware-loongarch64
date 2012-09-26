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
config etc/polkit-1/localauthority/50-local.d/20-plugdev-group-mount-override.pkla.new
config etc/polkit-1/localauthority/50-local.d/10-org.freedesktop.NetworkManager.pkla.new
