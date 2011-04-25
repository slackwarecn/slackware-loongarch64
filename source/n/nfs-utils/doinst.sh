#!/bin/sh
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
config var/lib/nfs/etab.new
config var/lib/nfs/rmtab.new
config var/lib/nfs/state.new
config var/lib/nfs/xtab.new
rm -f var/lib/nfs/*.new
if [ -x etc/rc.d/rc.nfsd ]; then
  chmod 755 etc/rc.d/rc.nfsd.new
else
  chmod 644 etc/rc.d/rc.nfsd.new
fi
config etc/rc.d/rc.nfsd.new
config etc/nfsmount.conf.new
config etc/exports.new
# If you already had your own /etc/exports, this one is probably useless...
rm -f etc/exports.new
( cd sbin ; rm -rf umount.nfs )
( cd sbin ; ln -sf mount.nfs umount.nfs )
( cd usr/man/man8 ; rm -rf rpc.mountd.8.gz )
( cd usr/man/man8 ; ln -sf mountd.8.gz rpc.mountd.8.gz )
( cd usr/man/man8 ; rm -rf rpc.nfsd.8.gz )
( cd usr/man/man8 ; ln -sf nfsd.8.gz rpc.nfsd.8.gz )
( cd usr/man/man8 ; rm -rf rpc.statd.8.gz )
( cd usr/man/man8 ; ln -sf statd.8.gz rpc.statd.8.gz )
( cd usr/man/man8 ; rm -rf rpc.sm-notify.8.gz )
( cd usr/man/man8 ; ln -sf sm-notify.8.gz rpc.sm-notify.8.gz )
( cd usr/sbin ; rm -rf rpc.statd )
( cd usr/sbin ; ln -sf ../../sbin/rpc.statd rpc.statd )
