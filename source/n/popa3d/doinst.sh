#!/bin/sh
# If the pop user/group don't exist, add them:
if ! grep -q "^pop:" etc/passwd ; then
  echo "pop:x:90:90:POP:/:" >> /etc/passwd
fi
if ! grep -q "^pop:" etc/group ; then
  echo "pop::90:pop" >> etc/group
fi

