
This is the source used for Slackware.

To look for a particular bit of source (let's say for 'cp'), first you would
look for the full path:

fuzzy:~# which cp
/bin/cp

Then, you grep for the package it came from. Note that the leading '/'
is removed, and ^ and $ mark the beginning and end of the pattern to match:

fuzzy:~# grep ^bin/cp$ /var/lib/pkgtools/packages/*
/var/lib/pkgtools/packages/coreutils-9.0-x86_64-3:bin/cp

From this, you can see that 'cp' came from the coreutils-9.0-x86_64-3 package.
The source will be found in a corresponding subdirectory. In this case, that
would be ./a/coreutils/.

All of these packages have scripts that extract, patch, and compile the source
automatically. These are the 'SlackBuild' scripts.

Have fun!

---
Patrick J. Volkerding
volkerdi@slackware.com
