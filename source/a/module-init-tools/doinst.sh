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
config etc/modprobe.conf.new

# Retain legacy behavior by tossing a symlink in /etc/modprobe.d/:
# Note that the plan is to eliminate /etc/modprobe.conf and
# /etc/modules.conf in the long run, so you may wish to remove the
# link and move your actual file into /etc/modprobe.d/ if you want
# to keep it instead of going with smaller chunks in there...
if [ -r etc/modprobe.conf ]; then
  ( cd etc/modprobe.d ; ln -s ../modprobe.conf . 2> /dev/null )
fi

