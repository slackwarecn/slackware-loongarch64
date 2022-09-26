#!/bin/bash
config() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  # If there's no config file by that name, mv it over:
  if [ ! -r $OLD ]; then
    mv $NEW $OLD
  elif [ "$(cat $OLD | md5sum)" = "$(cat $NEW | md5sum)" ]; then # toss the redundant copy
    rm $NEW
  fi
  # Otherwise, we leave the .new copy for the admin to consider...
}
config usr/share/vim/vimrc.new

# Responding to a report that in some cases the file
# /usr/share/vim/vim90/defaults.vim must be edited in order to change settings
# (some settings in the file will otherwise override those in
# /usr/share/vim/vimrc), we will support a file in the same directory named
# defaults.vim.custom. If this file exists, then it will replace the shipped
# version of defaults.vim. The original file will be preserved as
# defaults.vim.orig.
if [ -r usr/share/vim/vim90/defaults.vim.custom ]; then
  cp -a usr/share/vim/vim90/defaults.vim usr/share/vim/vim90/defaults.vim.orig
  cp -a usr/share/vim/vim90/defaults.vim.custom usr/share/vim/vim90/defaults.vim
fi
