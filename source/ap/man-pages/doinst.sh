#!/bin/sh
if [ ! -e usr/man/whatis ]; then
  mv usr/man/whatis.sample usr/man/whatis
elif [ "$(md5sum usr/man/whatis)" = "$(md5sum usr/man/whatis.sample)" ]; then
  # toss the redundant copy
  rm usr/man/whatis.sample
fi
