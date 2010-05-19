#!/bin/sh
# Copyright 2003  Slackware Linux, Inc., Concord, CA, USA
# All rights reserved.
#
# Redistribution and use of this script, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this script must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
#  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
#  EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
#  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
#  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# /usr/bin/btdownloadxterm.sh
# A simple script used in /etc/mailcap to enable using
# btdownloadcurses.py with Mozilla, etc.
#
# This goes in /etc/mailcap:
#application/x-bittorrent; /usr/bin/btdownloadxterm.sh '%s' ; 

# Create a directory for downloads:
if [ ! -d $HOME/BitTorrent ]; then
  mkdir -p $HOME/BitTorrent
fi

# Change to the download directory and start BitTorrent there:
cd $HOME/BitTorrent && exec /usr/X11R6/bin/xterm -e /usr/bin/btdownloadcurses.py "$1"

