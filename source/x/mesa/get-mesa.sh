rm -rf mesa
git clone git://anongit.freedesktop.org/git/mesa/mesa
# package the source archive and clean up:
( cd mesa ; find . -type d -name .git -exec rm -rf {} \; 2> /dev/null )
DATE=$(date +%Y%m%d)
mv mesa mesa-${DATE}_git
tar cjf mesa-${DATE}_git.tar.bz2 mesa-${DATE}_git
rm -rf mesa-${DATE}_git
