# Since the use of icon caching is optional, and has to be kept in sync
# somehow (like a "registry" through a cron job, or whatever, I tend to
# think the user should be the one to choose if they really want to set
# this up or not:
 
# Using an absolute path (/usr/bin/gtk-update-icon-cache) will make
# this script function only on a running system.  Otherwise an end-of-
# install script will take care of this job.

# Don't make a global cache in /usr/share/icons.  Not only is it huge,
# but it causes problems if it isn't constantly updated.
# |>@&^^ registries...  ;-)
#
# /usr/share/icons isn't really a "theme" anyway and shouldn't have a
# icon-theme.cache file there.
#
# If there already is a global cache, rm it:
rm -f usr/share/icons/icon-theme.cache

# Update hicolor theme cache:
if [ -d usr/share/icons/hicolor ]; then
  if [ -e usr/share/icons/hicolor/icon-theme.cache ]; then # ONLY run this if there's already a cache!!!
    if [ -x /usr/bin/gtk-update-icon-cache ]; then
      chroot . /usr/bin/gtk-update-icon-cache -f -t usr/share/icons/hicolor 1> /dev/null 2> /dev/null
    fi
  fi
fi
