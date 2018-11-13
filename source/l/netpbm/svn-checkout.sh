# Clear the download area:
rm -rf netpbm

# Stable (aka obsolete) version:
#svn checkout http://svn.code.sf.net/p/netpbm/code/stable netpbm

# Advanced version:
svn checkout https://svn.code.sf.net/p/netpbm/code/advanced netpbm
svn checkout https://svn.code.sf.net/p/netpbm/code/userguide netpbm/userguide
( cd netpbm && find -name "\.svn" -type d -print0 | xargs -0 rm -rf )
# Dropped due to patent issues:
rm -rf netpbm/converter/ppm/ppmtompeg/

# Tar it up:
eval $(cat netpbm/version.mk | tr -d ' ')
NETPBM_MAJOR_RELEASE=$(printf "%02d" $NETPBM_MAJOR_RELEASE)
NETPBM_MINOR_RELEASE=$(printf "%02d" $NETPBM_MINOR_RELEASE)
NETPBM_POINT_RELEASE=$(printf "%02d" $NETPBM_POINT_RELEASE)
rm -rf netpbm-${NETPBM_MAJOR_RELEASE}.${NETPBM_MINOR_RELEASE}.${NETPBM_POINT_RELEASE} netpbm-${NETPBM_MAJOR_RELEASE}.${NETPBM_MINOR_RELEASE}.${NETPBM_POINT_RELEASE}.tar netpbm-${NETPBM_MAJOR_RELEASE}.${NETPBM_MINOR_RELEASE}.${NETPBM_POINT_RELEASE}.tar.lz
mv netpbm netpbm-${NETPBM_MAJOR_RELEASE}.${NETPBM_MINOR_RELEASE}.${NETPBM_POINT_RELEASE}
tar cf netpbm-${NETPBM_MAJOR_RELEASE}.${NETPBM_MINOR_RELEASE}.${NETPBM_POINT_RELEASE}.tar netpbm-${NETPBM_MAJOR_RELEASE}.${NETPBM_MINOR_RELEASE}.${NETPBM_POINT_RELEASE}
plzip -9 netpbm-${NETPBM_MAJOR_RELEASE}.${NETPBM_MINOR_RELEASE}.${NETPBM_POINT_RELEASE}.tar
rm -r netpbm-${NETPBM_MAJOR_RELEASE}.${NETPBM_MINOR_RELEASE}.${NETPBM_POINT_RELEASE}
