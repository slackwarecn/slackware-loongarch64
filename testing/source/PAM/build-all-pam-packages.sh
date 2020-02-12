#!/bin/bash

cd $(dirname $0) ; CWD=$(pwd)

rm -rf /tmp/pam-packages
TMP=/tmp/pam-packages
export TMP
mkdir -p $TMP

BUILDLIST=$CWD/buildlist ./make_world.sh

# Give everything a _pam build suffix while it remains in /testing:
( cd $TMP
  for package in *.txz ; do
    mv $package $(basename $package .txz)_pam.txz
  done
)
