
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
# Slackware scripts
config etc/inittab.new
config etc/rc.d/rc.4.new
config etc/rc.d/rc.6.new
config etc/rc.d/rc.K.new
config etc/rc.d/rc.M.new
config etc/rc.d/rc.S.new
config etc/rc.d/rc.cpufreq.new
config etc/rc.d/rc.local.new
config etc/rc.d/rc.loop.new
config etc/rc.d/rc.sysvinit.new
config etc/rc.d/rc.modules.new
config etc/rc.d/rc.modules.local.new

( cd etc/rc.d ; rm -rf rc.0 )
( cd etc/rc.d ; ln -sf rc.6 rc.0 )

