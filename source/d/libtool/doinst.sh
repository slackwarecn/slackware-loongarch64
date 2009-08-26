# Update the /usr/info/dir info-database, so that we will see the new
# "libtool" item in info root structure, if we type "info".
if [ -x /usr/bin/install-info ] ; then
  install-info --info-dir=/usr/info /usr/info/libtool.info.gz 2>/dev/null
elif fgrep "libtoolize" usr/info/dir 1> /dev/null 2> /dev/null ; then
  GOOD=yes # It seems to be entered in the /usr/info/dir already
else # add the info to the dir file directly:
cat << EOF >> usr/info/dir

GNU programming tools
* libtoolize: (libtool)Invoking libtoolize.     Adding libtool support.
* Libtool: (libtool).           Generic shared library support script.

Individual utilities
* libtoolize: (libtool)Invoking libtoolize.     Adding libtool support.
* Libtool: (libtool).           Generic shared library support script.
EOF
fi
