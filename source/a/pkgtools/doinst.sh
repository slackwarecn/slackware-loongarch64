#!/bin/bash
# Migrate the package database and related directories from the long-time
# (stupid) directory /var/log to /var/lib/pkgtools.
#
# The removed_* directories will remain under /var/log (but moved to
# /var/log/pkgtools) as they contain log files of previous operations,
# not anything that's actively used for package management. Also, the
# removed_* directories can become quite large compared with the database.
#
# First, if it's just a case of missing symlinks, make them. Don't make them
# if the directories exist in /var/log - we'll do a proper migration in that
# case.
for directory in packages scripts setup ; do
  if [ ! -L var/log/$directory -a ! -d var/log/$directory ]; then
    if [ -d var/lib/pkgtools/$directory ]; then
      # Make the symlink:
      ( cd var/log ; ln -sf ../lib/pkgtools/$directory . )    
    fi
  fi
done
for directory in removed_packages removed_scripts ; do
  if [ ! -L var/log/$directory -a ! -d var/log/$directory ]; then
    mkdir -p var/log/pkgtools/$directory
    ( cd var/log ; ln -sf pkgtools/$directory . )
  fi
  if [ ! -L var/lib/pkgtools/$directory -a ! -d var/lib/pkgtools/$directory ]; then
    mkdir -p var/lib/pkgtools
    ( cd var/lib/pkgtools ; ln -sf ../../log/pkgtools/$directory . )
  fi
done
# If at this point /var/log/packages is not a symlink, we need to do the
# migration. We should already have a lock on being the only install script
# that's currently running, but also get a lock on ldconfig to freeze any
# other package operations that are happening now until after the migration
# is complete.
if [ ! -L var/log/packages ]; then
  if [ ! -d run/lock/pkgtools ]; then
    mkdir -p run/lock/pkgtools
  fi
  ( flock 9 || exit 11
    # Don't migrate if tar is running, as there may still be package operations
    # going on in another process:
    while pidof tar 1> /dev/null 2> /dev/null ; do
      sleep 15
    done
    # Just to be a bit safer from race conditions:
    sleep 5
    # First, move the removed_* directories into a pkgtools subdirectory:
    mkdir -p var/log/pkgtools
    for directory in removed_packages removed_scripts ; do
      if [ ! -d var/log/pkgtools/$directory ]; then
        mkdir -p var/log/pkgtools/$directory
        # Move anything found in the old location, then remove it:
        mv var/log/$directory/* var/log/pkgtools/$directory 2> /dev/null
        rm -rf var/log/$directory
        # Make a symlink:
        ( cd var/log ; ln -sf pkgtools/$directory . )
      fi 
    done
    for directory in packages scripts setup ; do
      mkdir -p var/lib/pkgtools/$directory
      mv var/log/$directory/* var/lib/pkgtools/$directory 2> /dev/null
      rm -rf var/log/$directory
      ( cd var/log
        ln -sf ../lib/pkgtools/$directory .
      )
    done
  ) 9> run/lock/pkgtools/ldconfig.lock
fi
