rm -rf xaw3d
git clone git://gitorious.org/xaw3d/xaw3d.git
( cd xaw3d && rm -rf .git* )
mv xaw3d xaw3d-$(date +%Y%m%d)git
tar cf xaw3d-$(date +%Y%m%d)git.tar xaw3d-$(date +%Y%m%d)git
xz -9 xaw3d-$(date +%Y%m%d)git.tar

