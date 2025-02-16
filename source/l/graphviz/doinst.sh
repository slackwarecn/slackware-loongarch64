config() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  # If there's no config file by that name, mv it over:
  if [ ! -r $OLD ]; then
    mv $NEW $OLD
  elif [ "$(cat $OLD|md5sum)" = "$(cat $NEW|md5sum)" ]; then
    # toss the redundant copy
    rm $NEW
  fi
  # Otherwise, we leave the .new copy for the admin to consider...
}

config etc/php.d/graphviz.ini.new

# Configure plugins (/usr/lib*/graphviz/config6):
chroot . /usr/bin/dot -c 1> /dev/null 2> /dev/null
