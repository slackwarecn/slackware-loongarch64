# Update the /usr/info/dir info-database, so that we will see the new
# "automake" item in info root structure, if we type "info".
if [ -x /usr/bin/install-info ] ; then
  install-info --info-dir=/usr/info /usr/info/automake.info.gz 2>/dev/null
elif fgrep "automake" usr/info/dir 1> /dev/null 2> /dev/null ; then
  GOOD=yes # It seems to be entered in the /usr/info/dir already
else # add the info to the dir file directly:
cat << EOF >> usr/info/dir

GNU admin
* aclocal: (automake)Invoking aclocal.          Generating aclocal.m4
* automake: (automake).         Making Makefile.in's
EOF
fi
