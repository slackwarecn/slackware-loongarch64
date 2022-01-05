#!/bin/bash
# Copyright 2022  Patrick J. Volkerding, Sebeka, Minnesota, USA
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

# This script will attempt to disable pipewire as the default audio server,
# changing it back to pulseaudio.

# Remove or rename the XDG autostart files:
for file in /etc/xdg/autostart/pipewire-media-session.desktop /etc/xdg/autostart/pipewire-pulse.desktop /etc/xdg/autostart/pipewire.desktop ; do
  if [ -r ${file}.sample ]; then
    rm -f $file
  elif [ -r $file ]; then
    mv ${file} ${file}.sample
  fi
done

# Enable pulseaudio.desktop:
if grep -q "^Hidden=true$" /etc/xdg/autostart/pulseaudio.desktop ; then
  grep -v "^Hidden=true$" /etc/xdg/autostart/pulseaudio.desktop > /etc/xdg/autostart/pulseaudio.desktop.new
  mv /etc/xdg/autostart/pulseaudio.desktop.new /etc/xdg/autostart/pulseaudio.desktop
fi

# Edit /etc/pulse/client.conf to enable autospawn:
sed -i "s/autospawn = no/autospawn = yes/g" /etc/pulse/client.conf
sed -i "s/allow-autospawn-for-root = no/allow-autospawn-for-root = yes/g" /etc/pulse/client.conf

echo "Pulseaudio enabled as system audio server."
if ps ax | grep -q pipewire ; then
  echo
  echo "You may need to stop running daemon/pipewire processes."
  echo "The clean way is to run these commands as the user that owns the processes:"
  echo "/usr/bin/daemon --pidfiles=~/.run --name=pipewire --stop"
  echo "/usr/bin/daemon --pidfiles=~/.run --name=pipewire-media-session --stop"
  echo "/usr/bin/daemon --pidfiles=~/.run --name=pipewire-pulse --stop"
  echo
  echo "The quick and dirty way if nothing else on the machine is using the daemon"
  echo "utility is to issue this command:"
  echo "killall daemon"
fi
