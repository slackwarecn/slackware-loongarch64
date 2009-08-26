#!/bin/sh
# Print a fortune cookie for interactive shells:
if [[ $- = *i* ]]; then
  echo
  fortune fortunes fortunes2 linuxcookie
  echo
fi
