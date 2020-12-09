# Handle the incoming configuration files:
config() {
  for infile in $1; do
    NEW="$infile"
    OLD="`dirname $NEW`/`basename $NEW .new`"
    # If there's no config file by that name, mv it over:
    if [ ! -r $OLD ]; then
      mv $NEW $OLD
    elif [ "`cat $OLD | md5sum`" = "`cat $NEW | md5sum`" ]; then
      # toss the redundant copy
      rm $NEW
    fi
    # Otherwise, we leave the .new copy for the admin to consider...
  done
}
preserve_perms() {
  NEW="$1"
  OLD="$(dirname ${NEW})/$(basename ${NEW} .new)"
  if [ -e ${OLD} ]; then
    cp -a ${OLD} ${NEW}.incoming
    cat ${NEW} > ${NEW}.incoming
    mv ${NEW}.incoming ${NEW}
  fi
  config ${NEW}
}

#
# Preserve permissions while moving into place:
preserve_perms etc/rc.d/rc.elogind.new
config etc/elogind/logind.conf.new
config usr/share/polkit-1/rules.d/10-enable-session-power.rules.new

if pgrep -f elogind-daemon | grep -q 'elogind-daemon'; then
  echo "Reloading elogind-daemon..."
  pkill -HUP -f elogind-daemon
fi

## Now taken care of in Slackware's /etc/rc.d/rc.M:
##
## Update rc.local so that elogind will be functional after boot:
#if ! grep "rc.elogind" etc/rc.d/rc.local 1>/dev/null 2>/dev/null ; then
#  cat <<_EOM_ >> etc/rc.d/rc.local
#
#if [ -x /etc/rc.d/rc.elogind ]; then
#  # Create runtime for elogind (standalone logind extracted from systemd):
#  /etc/rc.d/rc.elogind start
#fi
#_EOM_
#fi
