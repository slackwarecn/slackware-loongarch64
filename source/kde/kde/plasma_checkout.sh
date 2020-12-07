#!/bin/sh
# $id$
# -----------------------------------------------------------------------------
# Purpose: A script to checkout sources for KDE Plasma Next from the
#          git repositories and create tarballs of them.
# Author:  Eric Hameleers <alien@slackware.com>
# Date:    20140604
# -----------------------------------------------------------------------------

# Defaults:

# Directory where we start:
CWD=$(pwd)

# Cleanup (delete) the directories containing the local clones afterwards:
CLEANUP="NO"
 
# Checkout at a custom date instead of today:
CUSTDATE="NO"

# Forced overwriting of existing tarballs:
FORCE="NO"

# Where to write the files by default:
MYDIR="${CWD}/_plasma_checkouts"

# KDE git repositories:
KDEGITURI="git://anongit.kde.org"

# Prefered branch to check out from if it exists (HEAD otherwise):
BRANCH="frameworks"

# Shrink the tarball by removing git repository metadata:
SHRINK="YES"

# Today's timestamp:
THEDATE=$(date +%Y%m%d)

# The KDE topdirectory ( by default the location of this script):
TOPDIR=$(cd $(dirname $0); pwd)

# -----------------------------------------------------------------------------
while getopts "cd:fghk:o:" Option
do
  case $Option in
    c ) CLEANUP="YES"
        ;;
    d ) THEDATE="date --date='${OPTARG}' +%Y%m%d"
        CUSTDATE="${OPTARG}"
        ;;
    f ) FORCE="YES"
        ;;
    g ) SHRINK="NO"
        ;;
    k ) TOPDIR="${OPTARG}"
        ;;
    o ) MYDIR="${OPTARG}"
        ;;
    h|* ) 
        echo "$(basename $0) [<param> <param> ...] [<module> <module> ...]"
        echo "Parameters are:"
        echo "  -h            This help."
        echo "  -c            Cleanup afterwards (delete the cloned repos)."
        echo "  -d <date>     Checkout git at <date> instead of today."
        echo "  -f            Force overwriting of tarballs if they exist."
        echo "  -g            Keep git repository metadata (bigger tarball)."
        echo "  -o <dir>      Create tarballs in <dir> instead of $MYDIR/."
        echo "  -k <dir>      Location of KDE sources if not $(cd $(dirname $0), pwd)/."
        exit
        ;;
  esac
done

shift $(($OPTIND - 1))
# End of option parsing.
#  $1 now references the first non option item supplied on the command line
#  if one exists.
# -----------------------------------------------------------------------------

# Catch any individual requests on the commandline:
MODS=${1:-""}

# Verify that our TOPDIR is the KDE source top directory:
if ! [ -f ${TOPDIR}/KDE.SlackBuild -a -d ${TOPDIR}/src ]; then
  echo ">> Error: '$TOPDIR' does not seem to contain the KDE SlackBuild plus sources"
  echo ">> Either place this script in the KDE directory before running it,"
  echo ">> Or specify the KDE toplevel source directory with the '-k' parameter"
  exit 1
fi

# No modules specified on the commandline; get all enabled plasma modules:
if [ ! -n "$MODS" ]; then
  MODS="$(cat ${TOPDIR}/modules/plasma | grep -v " *#" | grep -v "^$")"
fi

# Create the work directory:
mkdir -p "${MYDIR}"
if [ $? -ne 0 ]; then
  echo "Error creating '${MYDIR}' - aborting."
  exit 1
fi
cd "${MYDIR}"

# Proceed with checking out all plasma-next sources.
# Some packages are called foo-framework to make them co-installable with the
# KDE4 packages with the same source-name. Strip the '-framework' off the
# package name to get the source name):

for MOD in $MODS ; do
  git clone ${KDEGITURI}/${MOD%-framework}.git ${MOD%-framework}-${THEDATE}git
  ( cd ${MOD%-framework}-${THEDATE}git
    git checkout ${BRANCH} # If this fails we should have 'master' anyway
    if [ $? -ne 0 ]; then
      BRANCH="master"
    fi
    if [ "$CUSTDATE" != "NO" ]; then
      # Checkout at a specified date instead of HEAD:
      git checkout $(git rev-list -n 1 --before="`date -d $THEDATE`" $BRANCH)
    fi
  )
done

if [ "$SHRINK" = "YES" ]; then
  # Remove git meta data from the tarballs:
  for DIR in $(ls |grep git$) ; do
    find ${DIR%/} -name ".git*" -depth -exec rm -rf {} \;
  done
fi

# Zip them up:
for DIR in $(ls |grep git$) ; do
  if [ "$FORCE" = "NO" -a -f ${DIR%/}.tar.xz ]; then
    echo ">> Not overwriting existng file '${DIR%/}.tar.xz'"
    echo ">> Use '-f' to force ovewriting existing files"
  else
    tar -Jcf ${DIR%/}.tar.xz ${DIR%/}
  fi
done

if [ "$CLEANUP" = "YES" ]; then
  # Remmove the cloned directories now that we have the tarballs:
  rm -r *git
fi

cd $CWD
# Done!
