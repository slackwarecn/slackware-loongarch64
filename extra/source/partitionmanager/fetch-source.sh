#!/bin/sh

NAME_VERSION=partitionmanager-1.0.3
SVN_DATE=$(date +%Y%m%d)

# Remove old sources if exist
rm -R --force ${NAME_VERSION}

# Checkout svn trunk
svn -r {${SVN_DATE}} export svn://anonsvn.kde.org/home/kde/trunk/extragear/sysadmin/partitionmanager/ ${NAME_VERSION}

# Move downloaded directory to match output tarball name:
mv ${NAME_VERSION} ${NAME_VERSION}_${SVN_DATE}svn

# Create source tarball
tar cvf ${NAME_VERSION}_${SVN_DATE}svn.tar ${NAME_VERSION}_${SVN_DATE}svn

# Compress source tarball
xz -9 -v ${NAME_VERSION}_${SVN_DATE}svn.tar

# Delete temporary directories
rm -R --force ${NAME_VERSION}_${SVN_DATE}svn
