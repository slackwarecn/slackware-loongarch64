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
config etc/logrotate.d/syslog.new
config etc/syslog.conf.new
config etc/rc.d/rc.syslog.new
config var/log/cron.new
config var/log/debug.new
config var/log/maillog.new
config var/log/messages.new
config var/log/secure.new
config var/log/spooler.new
config var/log/syslog.new

# Remove any leftover empty files:
rm -f var/log/cron.new
rm -f var/log/debug.new
rm -f var/log/maillog.new
rm -f var/log/messages.new
rm -f var/log/secure.new
rm -f var/log/spooler.new
rm -f var/log/syslog.new

