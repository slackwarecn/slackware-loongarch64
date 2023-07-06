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

# Keep same perms on rc.mysqld.new:
if [ -e etc/rc.d/rc.mysqld ]; then
  cp -a etc/rc.d/rc.mysqld etc/rc.d/rc.mysqld.new.incoming
  cat etc/rc.d/rc.mysqld.new > etc/rc.d/rc.mysqld.new.incoming
  mv etc/rc.d/rc.mysqld.new.incoming etc/rc.d/rc.mysqld.new
fi

config etc/rc.d/rc.mysqld.new
config etc/mysqlaccess.conf.new
config etc/my.cnf.new
config etc/my.cnf.d/client.cnf.new
config etc/my.cnf.d/hashicorp_key_management.cnf.new
config etc/my.cnf.d/mysql-clients.cnf.new
config etc/my.cnf.d/s3.cnf.new
config etc/my.cnf.d/server.cnf.new
config etc/my.cnf.d/spider.cnf.new
config etc/logrotate.d/mariadb.new

# This one is only comments, so remove it if it's left behind:
if [ -r etc/security/user_map.conf.new ]; then
  config etc/security/user_map.conf.new
fi
rm -f etc/security/user_map.conf.new

