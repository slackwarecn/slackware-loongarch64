#!/bin/sh
# A script to increment build numbers of all the dictionaries.
#
# Any that are newly added should not have a build file in
# here (or it should contain "1").  The usual method is to run this
# script and then remove the build files for any new driver versions.

for DICTSRC in ../src/* ; do
  DICTBASENAME=$(basename $DICTSRC | cut -f 1,2 -d -)
  ./increment.sh $DICTBASENAME
done

