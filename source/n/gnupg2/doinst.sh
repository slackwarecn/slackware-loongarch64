# If there's no /usr/bin/gpg, claim it:
if [ ! -e usr/bin/gpg ]; then
  ln -sf gpg2 usr/bin/gpg
fi
