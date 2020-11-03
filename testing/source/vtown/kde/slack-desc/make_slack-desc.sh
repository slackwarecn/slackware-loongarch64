#!/bin/bash
#
# Parameter #1: packagename
#
if [ -z "$1" ]; then
  echo "Need package name as 1st parameter!"
  exit 1
fi
PRGNAM="$1"

if [ -f "$PRGNAM" ]; then
  echo "A slack-desc file with name '$PRGNAM' already exists, will not overwrite!"
  exit 1
fi

HOMEPAGE=${HOMEPAGE:-"http://www.kde.org/"}
DESCR=${DESCR:-"short description here"}
MAXDESCR=$(( 70-3-${#PRGNAM} ))
if [ ${#DESCR} -gt $MAXDESCR ]; then
  DESCR=${DESCR:0:$MAXDESCR}
fi

SPCS=""; while [ ${#SPCS} -lt ${#PRGNAM} ]; do SPCS=" $SPCS";done

cat <<EOT > "$PRGNAM"
# HOW TO EDIT THIS FILE:
# The "handy ruler" below makes it easier to edit a package description. Line
# up the first '|' above the ':' following the base package name, and the '|'
# on the right side marks the last column you can put a character in. You must
# make exactly 11 lines for the formatting to be correct. It's also
# customary to leave one space after the ':'.

${SPCS}|-----handy-ruler------------------------------------------------------|
${PRGNAM}: ${PRGNAM} (${DESCR})
${PRGNAM}:
${PRGNAM}:
${PRGNAM}:
${PRGNAM}:
${PRGNAM}:
${PRGNAM}:
${PRGNAM}:
${PRGNAM}:
${PRGNAM}: Home page: ${HOMEPAGE}
${PRGNAM}:
EOT
