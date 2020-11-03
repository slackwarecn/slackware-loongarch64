#!/bin/bash
# Update the combined build numbers from the native and vtown build numbers.
for native in native-build-number/* ; do
  BUILDFILE=$(basename $native)
  if [ "$BUILDFILE" = "increment.sh" ]; then
    continue
  fi
  OLDCONTENTS=$(cat $BUILDFILE 2> /dev/null)
  NEWCONTENTS="$(cat $native)_vtown_$(cat vtown-build-number/$(basename $native))"
  if [ ! "$OLDCONTENTS" = "$NEWCONTENTS" ]; then
    echo "Uplifting $BUILDFILE"
    echo $NEWCONTENTS > $BUILDFILE
  fi
done
