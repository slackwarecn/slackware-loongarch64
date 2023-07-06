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

# Actually, with this being auto-generated and strongly tied to the
# filelist in this package, it's not a good idea to try to preserve
# this config file. For local certs, simply install them in the
# /usr/local/share/ca-certificates directory.
#config etc/ca-certificates.conf.new

# We don't want to run this from the installer because we've got a script
# that runs it after all the packages are installed. But if we do run it,
# we should chroot into the target partition to make sure the updates are
# done in the correct location (and not on the calling partition):
if [ ! -r /usr/lib/setup/setup ]; then
  chroot . /usr/sbin/update-ca-certificates --fresh 1> /dev/null 2> /dev/null
fi

