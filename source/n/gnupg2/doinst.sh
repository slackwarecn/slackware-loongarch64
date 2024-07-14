# If there's no /usr/bin/gpg, claim it:
if [ ! -e usr/bin/gpg ]; then
  ln -sf gpg2 usr/bin/gpg
fi
# If there's no /usr/bin/gpgv, claim it:
if [ ! -e usr/bin/gpgv ]; then
  ln -sf gpgv2 usr/bin/gpgv
fi
