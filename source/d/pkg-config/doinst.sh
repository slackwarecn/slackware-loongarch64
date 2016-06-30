# Break the /usr/share/pkgconfig symlinks, if it exists.
# Then move the .pc files to the standard location.
if [ -L usr/share/pkgconfig ]; then
  rm usr/share/pkgconfig
  mkdir -p usr/share/pkgconfig
  grep usr/share/pkgconfig var/log/packages/* | grep '\.pc$' | cut -f 2 -d : | cut -f 4 -d / | while read movefile ; do
    mv usr/lib/pkgconfig/$movefile usr/share/pkgconfig 1> /dev/null 2> /dev/null
  done
fi
