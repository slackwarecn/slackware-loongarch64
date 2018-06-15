# In order to properly handle time before /usr is mounted (in
# the event that /usr is a separate partition, which for a number
# of reasons isn't really a great idea), the /etc/localtime file
# should be a copy of the desired zoneinfo file and not a symlink
# to a file in /usr/share/zoneinfo. But if we find a symlink here
# we should defer to the admin's wishes and leave it alone.
#
# Note that setting the timezone with timeconfig will wipe both
# /etc/localtime and /etc/localtime-copied from.
# /etc/localtime-copied-from will be a symlink to a file under
# /usr/share/zoneinfo, and /etc/localtime will be a copy of that file.

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

# If we have no /etc/localtime, but we do have a localtime-copied-from
# symlink to locate what we would want there, then add a copy now:
if [ ! -r etc/localtime -a -L etc/localtime-copied-from ]; then
  chroot . /bin/cp etc/localtime-copied-from etc/localtime
fi

# Add the default timezone in /etc, if none exists:
if [ ! -r etc/localtime -a ! -L etc/localtime-copied-from ]; then
  ( cd etc ; rm -rf localtime localtime-copied-from )
  ( cd etc ; ln -sf /usr/share/zoneinfo/Factory localtime-copied-from )
fi

# Make sure /etc/localtime is updated, unless it is a symlink (in which
# case leave it alone):
if [ ! -L etc/localtime ]; then
  chroot . /bin/cp etc/localtime-copied-from etc/localtime
fi

# Add a link to the timeconfig script in /usr/share/zoneinfo:
( cd usr/share/zoneinfo ; rm -rf timeconfig )
( cd usr/share/zoneinfo ; ln -sf /usr/sbin/timeconfig timeconfig )
### Make the rest of the symbolic links in the zoneinfo database:
