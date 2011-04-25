# Remove/move obsolete configuration:
if [ -L etc/modprobe.d/modprobe.conf ]; then
  rm -f etc/modprobe.d/modprobe.conf
fi
if [ -e etc/modprobe.conf ]; then
  mv etc/modprobe.conf etc/modprobe.conf.obsolete
fi
