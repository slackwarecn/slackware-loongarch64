#!/bin/bash
config() {
  NEW="$1"
  OLD="$( dirname $NEW )/$( basename $NEW .new )"
  # If there's no config file by that name, mv it over:
  if [ ! -r $OLD ]; then
    mv $NEW $OLD
  elif [ "$( md5sum < $OLD )" = "$( md5sum < $NEW )" ]; then # toss the redundant copy
    rm $NEW
  fi
  # Otherwise, we leave the .new copy for the admin to consider...
}

