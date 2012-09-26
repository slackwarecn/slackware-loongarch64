# ---------------------------------------------------------------------------
# This script creates a directory structure below /usr/lib/jvm and populates
# it with symlinks to GCC binaries.
# This will work as a compatibility layer to emulate an Oracle JDK/JRE.
# This emulation is required in order to compile OpenJDK using GNU java.
#
# The same can automatically be achieved in Slackware's gcc packages if
# the 'configure' command is called with the following additional parameters:
#     --enable-java-home \
#     --with-java-home=/usr/lib$LIBDIRSUFFIX/jvm/jre \
#     --with-jvm-root-dir=/usr/lib$LIBDIRSUFFIX/jvm \
#     --with-jvm-jar-dir=/usr/lib$LIBDIRSUFFIX/jvm/jvm-exports \
#     --with-arch-directory=$LIB_ARCH \
#
# Author: Eric Hameleers <alien@slackware.com> December 2011
# ---------------------------------------------------------------------------

# Automatically determine the architecture we're building on:
if [ -z "$ARCH" ]; then
  case "$( uname -m )" in
    i?86) export ARCH=i486 ;;
    arm*) export ARCH=arm ;;
    # Unless $ARCH is already set, use uname -m for all other archs:
       *) export ARCH=$( uname -m ) ;;
  esac
fi

if [ "$ARCH" = "i486" ]; then
  SLKCFLAGS="-O2 -march=i486 -mtune=i686"
  LIBDIRSUFFIX=""
  LIB_ARCH=i386
elif [ "$ARCH" = "i686" ]; then
  SLKCFLAGS="-O2 -march=i686 -mtune=i686"
  LIBDIRSUFFIX=""
  LIB_ARCH=i386
elif [ "$ARCH" = "x86_64" ]; then
  SLKCFLAGS="-O2 -fPIC"
  LIBDIRSUFFIX="64"
  LIB_ARCH=amd64
else
  SLKCFLAGS="-O2"
  LIBDIRSUFFIX=""
  LIB_ARCH=$ARCH
fi

# Where does the OpenJDK SlackBuild expect the GNU java compatibility symlinks:
JVM=${1:-/usr/lib${LIBDIRSUFFIX}/jvm}
BINDIR=/usr/bin

# What version of GCC do we have installed:
GCJVER=$(gcj -dumpversion)

# First, remove the old set of symlinks if they should exist:
rm -fr $JVM

# Create a JDK compatible directory structure for GNU java:
mkdir -p $JVM
mkdir -p $JVM/bin
mkdir -p $JVM/jre/bin
mkdir -p $JVM/jre/lib/${LIB_ARCH}/client
mkdir -p $JVM/jre/lib/${LIB_ARCH}/server
mkdir -p $JVM/lib

ln -sf $BINDIR/gjar $JVM/bin/jar
ln -sf $BINDIR/grmic $JVM/bin/rmic
ln -sf $BINDIR/gjavah $JVM/bin/javah
ln -sf $BINDIR/jcf-dump $JVM/bin/javap
ln -sf $BINDIR/gappletviewer $JVM/bin/appletviewer
ln -sf $BINDIR/grmiregistry $JVM/bin/rmiregistry
ln -sf $BINDIR/grmiregistry $JVM/jre/bin/rmiregistry
ln -sf $BINDIR/gkeytool $JVM/bin/keytool
ln -sf $BINDIR/gkeytool $JVM/jre/bin/keytool
ln -sf $BINDIR/gij $JVM/bin/java
ln -sf $BINDIR/ecj $JVM/bin/javac
ln -sf /usr/lib/gcj-${GCJVER}-11/libjvm.so $JVM/jre/lib/${LIB_ARCH}/client/libjvm.so
ln -sf /usr/lib/gcj-${GCJVER}-11/libjvm.so $JVM/jre/lib/${LIB_ARCH}/server/libjvm.so
ln -sf /usr/lib/gcj-${GCJVER}-11/libjawt.so $JVM/jre/lib/${LIB_ARCH}/libjawt.so
ln -sf /usr/share/java/libgcj-${GCJVER}.jar $JVM/jre/lib/rt.jar
ln -sf /usr/share/java/libgcj-tools-${GCJVER}.jar $JVM/lib/tools.jar
ln -sf /usr/include/c++/${GCJVER}/gnu/java $JVM/include

# Add a Eclipse Java Compiler wrapper which is required
# for bootstrapping OpenJDK using GNU java:
cat <<EOT > /usr/bin/ecj
#!/bin/sh

CLASSPATH=/usr/share/java/ecj.jar\${CLASSPATH:+:}\$CLASSPATH \
  java org.eclipse.jdt.internal.compiler.batch.Main "\$@"

EOT
chmod 755 /usr/bin/ecj


