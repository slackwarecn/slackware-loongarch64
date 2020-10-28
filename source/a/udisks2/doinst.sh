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

config etc/udisks2/udisks2.conf.new

# udisks2 is stupid about testing files before using them.  If /etc/crypttab
# does not exist, it will fill the log with "errors" as it tries to open the
# nonexistent file.  There's really no reason that a system without encrypted
# volumes should require this file, but nobody upstream cares to fix the
# problem (and the code's too messy for me to find it), so we have little
# choice but to trowel over this.  (sigh)

if [ ! -r etc/crypttab ]; then
  # echo "HEY, EVERYONE SHOULD HAVE A CRYPTTAB!!!"  (just kidding)
  touch etc/crypttab
fi
