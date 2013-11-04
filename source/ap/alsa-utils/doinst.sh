if [ -r etc/asound.state -a ! -r var/lib/alsa/asound.state -a ! -L etc/asound.state ]; then
  mv etc/asound.state var/lib/alsa
fi
# Better a dangling symlink than for nobody to know where this went:
rm -f etc/asound.state
( cd etc && ln -sf ../var/lib/alsa/asound.state . )

# Duplicate permissions from any existing rc scripts:
if [ -e etc/rc.d/rc.alsa ]; then
  if [ -x etc/rc.d/rc.alsa ]; then
    chmod 755 etc/rc.d/rc.alsa.new
  else
    chmod 644 etc/rc.d/rc.alsa.new
  fi
fi
if [ -e etc/rc.d/rc.alsa-oss ]; then
  if [ -x etc/rc.d/rc.alsa-oss ]; then
    chmod 755 etc/rc.d/rc.alsa-oss.new
  else
    chmod 644 etc/rc.d/rc.alsa-oss.new
  fi
fi

# Move the scripts into place:
mv etc/rc.d/rc.alsa.new etc/rc.d/rc.alsa
mv etc/rc.d/rc.alsa-oss.new etc/rc.d/rc.alsa-oss

