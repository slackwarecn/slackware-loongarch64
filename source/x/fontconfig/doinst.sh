# Update the X font indexes:
if [ -x /usr/bin/fc-cache ]; then
  /usr/bin/fc-cache -f
fi
# else we'll catch it later with setup.fontconfig :-)

# With fontconfig-2.15.0 we use the default of /usr/share/fontconfig/conf.avail
# so if we find any of "our" files in the old location, it's possible that they
# rode the old symlink there prior to this package being installed. Let's make
# sure that they get home OK.
if [ -d etc/fonts/conf.avail ]; then
  grep usr/share/fontconfig/conf.avail/ var/lib/pkgtools/packages/* | cut -f 2 -d : | sort | uniq | grep -v "/$" | while read conf ; do
    etcconf="etc/fonts/$(echo $conf | cut -f 4- -d /)"
    if [ ! -r $conf -a -r $etcconf ]; then
      mv $etcconf $conf
    else
      rm -f $etcconf
    fi
  done
fi
# If we can, get rid of this. Could be held by third-party packages though.
rmdir etc/fonts/conf.avail 2> /dev/null
