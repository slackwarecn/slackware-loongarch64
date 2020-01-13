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
config etc/vi.exrc.new

# If there's no vi link, take over:
if [ ! -r usr/bin/vi ]; then
  ( cd usr/bin ; ln -sf nvi vi )
fi

# If there's no ex link, take over:
if [ ! -r usr/bin/ex ]; then
  ( cd usr/bin ; ln -sf nex ex )
fi
