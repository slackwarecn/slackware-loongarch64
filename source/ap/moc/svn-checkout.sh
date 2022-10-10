# Clear the download area:
rm -rf moc

svn checkout svn://svn.daper.net/moc/trunk moc

( cd moc && find -name "\.svn" -type d -print0 | xargs -0 rm -rf )

# Tar it up:
VERSION="$(grep PROJECT_NUMBER moc/Doxyfile | cut -f 2 -d = | tr -d ' ' | tr - _)"
mv moc moc-${VERSION}
tar cf moc-${VERSION}.tar moc-${VERSION}
rm -f moc-${VERSION}.tar.lz
plzip -9 moc-${VERSION}.tar
rm -r moc-${VERSION}
