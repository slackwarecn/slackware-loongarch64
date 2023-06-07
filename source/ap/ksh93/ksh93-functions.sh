#!/bin/sh
# If $SHELL is /bin/ksh and this script is executable, enable these functions:
#
# pushd        Change directory and add to the top of the stack
# popd         Remove the top directory from the stack and change to
#              the previous directory in the stack
# dirs         List directories in the stack
#
# In addition, the following functions can be enabled with autoload:
#
# mcd          Menu-driven cd to directories in the stack
# cd           cd with a number as the first argument changes to the
#              directory in that position in the stack
# man          ksh builtins with the --man option included (typeset, cd,
#              etc.) can be looked up with man and fed through the pager
# autocd       Change directories by typing in the directory name only
#
# Calling pushd, popd, dirs or (autoloaded) mcd in ksh will autoload the cd
# function, overriding the cd builtin. Use "command cd" for the cd builtin.

if [ "$SHELL" = /bin/ksh ]; then
  FPATH=/usr/share/ksh93-functions
  export FPATH
fi
