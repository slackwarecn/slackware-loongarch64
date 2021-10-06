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

if [ -x /usr/sbin/update-ca-certificates ]; then
  /usr/sbin/update-ca-certificates --fresh 1> /dev/null 2> /dev/null
fi

