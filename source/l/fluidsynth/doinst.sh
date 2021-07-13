# If there's no default soundfont and minuet is installed, point to that one:
if [ ! -r usr/share/soundfonts/default.sf2 ]; then
  if [ -r usr/share/minuet/soundfonts/GeneralUser-v1.47.sf2 ]; then
    ln -sf /usr/share/minuet/soundfonts/GeneralUser-v1.47.sf2 usr/share/soundfonts/default.sf2
  fi
fi
