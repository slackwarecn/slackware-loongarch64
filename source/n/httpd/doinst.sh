#!/bin/sh

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

preserve_perms() {
  NEW="$1"
  OLD="$(dirname ${NEW})/$(basename ${NEW} .new)"
  if [ -e ${OLD} ]; then
    cp -a ${OLD} ${NEW}.incoming
    cat ${NEW} > ${NEW}.incoming
    mv ${NEW}.incoming ${NEW}
  fi
  config ${NEW}
}

if [ ! -e var/log/httpd ]; then
  mkdir -p var/log/httpd
  chmod 755 var/log/httpd
fi

# Don't wipe out an existing document root with symlinks. If someone has
# replaced the symlinks that are created on a fresh installation, assume
# that they know what they are doing and leave things as-is.
if [ ! -e srv/www ]; then
  ( cd srv ; ln -sf /var/www www )
fi
if [ ! -e srv/httpd ]; then
  ( cd srv ; ln -sf /var/www httpd )
fi

# Once again, our intent is not to wipe out anyone's
# site, but building in Apache's docs tree is not as
# good an idea as picking a unique DocumentRoot.
#
# Still, we will do what we can here to mitigate
# possible site damage:
if [ -r var/www/htdocs/index.html ]; then
  if [ ! -r "var/log/packages/httpd-*upgraded*" ]; then
    if [ var/www/htdocs/index.html -nt var/log/packages/httpd-*-? ]; then
      cp -a var/www/htdocs/index.html var/www/htdocs/index.html.bak.$$
    fi
  fi
fi

# Keep same perms when installing rc.httpd.new:
preserve_perms etc/rc.d/rc.httpd.new

# Handle config files.  Unless this is a fresh installation, the
# admin will have to move the .new files into place to complete
# the package installation, as we don't want to clobber files that
# may contain local customizations.
config etc/httpd/httpd.conf.new
config etc/logrotate.d/httpd.new
for conf_file in etc/httpd/extra/*.new; do
  config $conf_file
done
config var/www/htdocs/index.html.new

