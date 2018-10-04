#!/bin/sh
#
# This script should be run in the current directory if you wish to uninstall
# the pure ALSA packages and switch back to using Pulseaudio.

removepkg --terse xfce4-mixer xfce4-volumed
for package in MPlayer alsa-lib alsa-plugins audacious-plugins ffmpeg \
  fluidsynth gst-plugins-good gst-plugins-good0 kde-runtime kmix libao \
  pulseaudio pamixer pavucontrol xfce4-pulseaudio-plugin \
  libcanberra mpg123 phonon sox xine-lib ; do
  upgradepkg --install-new --terse ../../slackware*/*/${package}-*.txz
done
mv /etc/asound.conf.new /etc/asound.conf
echo "System is converted back to using Pulseaudio."
