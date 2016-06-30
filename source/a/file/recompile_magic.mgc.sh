#!/bin/sh
#
# Recompile the /etc/file/magic.mgc database.
# This should be done after any additions or changes to the files
# in /etc/file/magic/.

if [ ! "$UID" = "0" ]; then
  echo "Error:  must be root to recompile the system magic.mgc"
  exit 1
fi

cd /etc/file
/usr/bin/file --compile

