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

preserve_perms etc/rc.d/rc.iceccd.new
preserve_perms etc/rc.d/rc.icecc-scheduler.new
config etc/rc.d/rc.icecream.conf.new

if ! grep -q "^icecc:" etc/passwd ; then
  echo "icecc:x:49:49:User for Icecream distributed compiler:/var/cache/icecream:/bin/false" >> etc/passwd
fi
if ! grep -q "^icecc:" etc/group ; then
  echo "icecc:x:49:" >> etc/group
fi
