# Note on configuration change (2020-12-09):
# For the past decade and a half, this package has created a symlink
# /etc/localtime-copied-from and a file /etc/localtime to prevent
# time skew until /usr is mounted. But having a separate /usr partition
# hasn't really made sense for a long time and leads to all kinds of
# bugs these days. We're going to make /etc/localtime a symlink just
# like everyone else does so that programs that expect it to be a link
# can fetch the timezone without requiring any special patches.
# If you insist on making /usr a seperate partition, you might want to
# put the pointed-to directories and timezone file in your empty /usr
# directory so that it is available before the real /usr is mounted.
# Still not recommended though.

# In a special case, we will handle the removal of the US/Pacific-New
# timezone. A bit of background information on this:
#
# "US/Pacific-New' stands for 'Pacific Presidential Election Time',
# which was passed by the House in April 1989 but never signed into law.
# In presidential election years, this rule would have delayed the
# PDT-to-PST switchover until after the election, to lessen the effect
# of broadcast news election projections on last-minute west-coast
# voters. "
#
# In nearly all cases, a machine that uses the US/Pacific-New timezone
# has chosen it by mistake. In 2016, having this as the system timezone
# actually led to clock errors, and after that it was decided that the
# timezone (only of historical interest anyway) should be removed from
# the timezone database.
#
# If we see that the machine's localtime-copied-from symlink is pointing
# to US/Pacific-New, change it to point to US/Pacific instead.
if [ "$(/bin/ls -l etc/localtime-copied-from 2> /dev/null | rev | cut -f 1,2 -d / | rev)" = "US/Pacific-New" ]; then
  ( cd etc ; rm -rf localtime-copied-from )
  ( cd etc ; ln -sf /usr/share/zoneinfo/US/Pacific localtime-copied-from )
fi
# Same with any /etc/localtime symlink:
if [ -L etc/localtime ]; then
  if [ "$(/bin/ls -l etc/localtime 2> /dev/null | rev | cut -f 1,2 -d / | rev)" = "US/Pacific-New" ]; then
    ( cd etc ; rm -rf localtime )
    ( cd etc ; ln -sf /usr/share/zoneinfo/US/Pacific localtime )
  fi
fi

# If we already have a localtime-copied-from symlink, move it over as the
# /etc/localtime symlink:
if [ -L etc/localtime-copied-from ]; then
  rm -f etc/localtime
  mv etc/localtime-copied-from etc/localtime
fi

# Add the default timezone in /etc, if none exists:
if [ ! -r etc/localtime ]; then
  ( cd etc ; rm -rf localtime localtime-copied-from )
  ( cd etc ; ln -sf /usr/share/zoneinfo/Factory localtime-copied-from )
fi

# Add a link to the timeconfig script in /usr/share/zoneinfo:
( cd usr/share/zoneinfo ; rm -rf timeconfig )
( cd usr/share/zoneinfo ; ln -sf /usr/sbin/timeconfig timeconfig )
### Make the rest of the symbolic links in the zoneinfo database:
