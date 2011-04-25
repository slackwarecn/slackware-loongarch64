if [ ! -r etc/httpd/mod_php.conf ]; then
  cp -a etc/httpd/mod_php.conf.example etc/httpd/mod_php.conf
elif [ "`cat etc/httpd/mod_php.conf 2> /dev/null`" = "" ]; then
  cp -a etc/httpd/mod_php.conf.example etc/httpd/mod_php.conf
fi
if [ ! -r etc/httpd/php.ini ]; then
   cp -a etc/httpd/php.ini-production etc/httpd/php.ini
fi
