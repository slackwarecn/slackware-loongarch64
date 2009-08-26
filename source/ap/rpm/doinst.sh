if [ ! -r var/lib/rpm/Packages ]; then
  ( cd var/lib/rpm/tmp ; cp -a * .. )
fi
( cd var/lib/rpm && rm -f tmp/* && rmdir tmp )
# Symlinks:
