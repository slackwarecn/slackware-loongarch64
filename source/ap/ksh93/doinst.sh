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

preserve_perms() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  if [ -e $OLD ]; then
    cp -a $OLD ${NEW}.incoming
    cat $NEW > ${NEW}.incoming
    mv ${NEW}.incoming $NEW
  fi
  config $NEW
}

preserve_perms etc/profile.d/ksh93-functions.sh.new

# Backup the old copy if we find one, move the new one in place
if [ -f bin/ksh ]; then
   mv bin/ksh bin/ksh.old
fi
mv bin/ksh.new bin/ksh
if [ -f bin/ksh.old ]; then
  rm -f bin/ksh.old
fi

# Add entries to /etc/shells if we need them
if [ ! -r etc/shells ] ; then
   touch etc/shells
   chmod 644 etc/shells
fi

if ! grep -q "/bin/ksh" etc/shells ; then
   echo "/bin/ksh" >> etc/shells
fi
