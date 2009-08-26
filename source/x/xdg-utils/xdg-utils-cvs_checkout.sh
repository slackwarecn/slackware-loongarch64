#!/bin/bash


MODULE=$(basename $0 -cvs_checkout.sh)
DATE=$(date +%Y%m%d)

set -x

rm -rf $MODULE

cvs -z3 -d:pserver:anonymous@cvs.freedesktop.org:/cvs/portland checkout -P portland/$MODULE 
pushd portland
find . -name CVS -exec rm -rf "{}" \; 2> /dev/null
tar cjf ../$MODULE-${DATE}cvs.tar.bz2 $MODULE
popd

rm -rf portland 
