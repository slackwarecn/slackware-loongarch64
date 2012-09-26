
This is the source used for Slackware.

To look for a particular bit of source (let's say for 'cp'), first you would
look for the full path:

fuzzy:~# which cp
/bin/cp

Then, you grep for the package it came from. Note that the leading '/'
is removed:

fuzzy:~# grep bin/cp /var/log/packages/*
/var/log/packages/cpio-2.4.2.91-i386-1:bin/cpio
/var/log/packages/fileutils-4.1-i386-2:bin/cp
/var/log/packages/gcc-2.95.3-i386-2:usr/bin/cpp
/var/log/packages/gnome-applets-1.4.0.5-i386-1:usr/bin/cpumemusage_applet


From this, you can see that 'cp' came from the fileutils-4.1-i386-2 package.
The source will be found in a corresponding subdirectory.  In this case, that
would be ./a/bin.   Don't be fooled into thinking that the _bin.tar.gz in this
directory is the package with the source code -- anything starting with '_' is
just a framework package full of empty files with the correct permissions and 
ownerships for the completed package to use.

Many of these packages now have scripts that untar, patch, and compile the
source automatically.  These are the 'SlackBuild' scripts.  Moving back to the
example above, you can figure out which package the bin/cp source came from by
examining the SlackBuild script.

Have fun!

---
Patrick J. Volkerding
volkerdi@slackware.com
