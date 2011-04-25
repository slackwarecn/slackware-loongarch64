if [ -r etc/asound.state -a ! -r var/lib/alsa/asound.state -a ! -L etc/asound.state ]; then
  mv etc/asound.state var/lib/alsa
fi
# Better a dangling symlink than for nobody to know where this went:
rm -f etc/asound.state
( cd etc && ln -sf ../var/lib/alsa/asound.state . )
