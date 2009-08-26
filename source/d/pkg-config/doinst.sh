if [ ! -L usr/share/pkgconfig ]; then
  mkdir -p usr/lib/pkgconfig 2> /dev/null
  mv usr/share/pkgconfig/* usr/lib/pkgconfig 2> /dev/null
  rmdir usr/share/pkgconfig 2> /dev/null
  ( cd usr/share ; ln -sf ../lib/pkgconfig . 2> /dev/null )
fi
