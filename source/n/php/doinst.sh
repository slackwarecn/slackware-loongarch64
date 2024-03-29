if [ "`cat etc/httpd/mod_php.conf 2> /dev/null`" = "" ]; then
  cp -a etc/httpd/mod_php.conf.new etc/httpd/mod_php.conf
fi

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
# Keep same perms on rc.php-fpm.new:
if [ -e etc/rc.d/rc.php-fpm ]; then
  cp -a etc/rc.d/rc.php-fpm etc/rc.d/rc.php-fpm.new.incoming
  cat etc/rc.d/rc.php-fpm.new > etc/rc.d/rc.php-fpm.new.incoming
  mv etc/rc.d/rc.php-fpm.new.incoming etc/rc.d/rc.php-fpm.new
fi
config etc/rc.d/rc.php-fpm.new
cp -a etc/php.ini-production etc/php.ini.new
config etc/php.ini.new
cp -a etc/php-fpm.conf.default etc/php-fpm.conf.new
config etc/php-fpm.conf.new
cp -a etc/php-fpm.d/www.conf.default etc/php-fpm.d/www.conf.new
config etc/php-fpm.d/www.conf.new
config etc/httpd/mod_php.conf.new
