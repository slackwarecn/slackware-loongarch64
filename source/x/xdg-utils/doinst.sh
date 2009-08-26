#!/bin/sh
# Regarding xdg-open in /etc/mailcap:
#
# It turns out that xdg-open is not very smart about what it
# passes off control to, leading to security problems where (for
# example) a file could be provided on a web site as a PDF, but
# rather than send it to a PDF viewer, xdg-open sends it to kfmclient
# which uses a whole different set of criteria to determine what sort
# of file it is.  It's trivial to make something that's detected as
# a PDF at first, but then is executed as a .desktop file later,
# resulting in the execution of arbitrary code as the user.
#
# This is not acceptable, and we see no way to fix it as long as
# xdg-open passes off the resolution of the file type (again) to
# something else.  In light of the potential security risks, we
# will turn off the use of xdg-open if it appears to have been
# added by a previous version of the xdg-utils package.
#
# Vulnerability code:  CVE-2009-0068

# First, we will detect an automatically modified mailcap by
# looking for the comment "# Sample xdg-open entries:"

if [ -r etc/mailcap ]; then
  if grep -q "^# Sample xdg-open entries:$" etc/mailcap ; then

    COOKIE=$(usr/bin/mcookie)
    if [ -z $COOKIE ]; then
      exit 1
    fi

    # First, add a space to the end of the comment used to detect this
    # junk so that we won't detect it again (in case the user decides
    # to enable this themselves later on -- their call).  Add a warning
    # about this type of xdg-open use being insecure.  Finally, comment
    # out any lines like this.

    echo "# Sample xdg-open entries: " > tmp/mailcap-$COOKIE
    cat << EOF >> tmp/mailcap-$COOKIE
#
# NOTE:  Using xdg-open in /etc/mailcap in this way has been
# shown to be insecure and is not recommended (CVE-2009-0068)!
# A remote attacker can easily make a filetype such as a
# .desktop script appear to xdg-open as a PDF file causing its
# arbitrary contents to be executed.  Consider these to be
# examples of what NOT to do.  The xdg-utils package no longer
# adds any lines such as these to /etc/mailcap.
#
EOF
    cat etc/mailcap \
    | grep -v "# Sample xdg-open entries:" \
    | sed -e 's/^audio\/\*; \/usr\/bin\/xdg-open %s/#audio\/\*; \/usr\/bin\/xdg-open %s/g' \
    | sed -e 's/^image\/\*; \/usr\/bin\/xdg-open %s/#image\/\*; \/usr\/bin\/xdg-open %s/g' \
    | sed -e 's/^application\/msword; \/usr\/bin\/xdg-open %s/#application\/msword; \/usr\/bin\/xdg-open %s/g' \
    | sed -e 's/^application\/pdf; \/usr\/bin\/xdg-open %s/#application\/pdf; \/usr\/bin\/xdg-open %s/g' \
    | sed -e 's/^application\/postscript ; \/usr\/bin\/xdg-open %s/#application\/postscript ; \/usr\/bin\/xdg-open %s/g' \
    | sed -e 's/^text\/html; \/usr\/bin\/xdg-open %s ; copiousoutput/#text\/html; \/usr\/bin\/xdg-open %s ; copiousoutput/g' >> tmp/mailcap-$COOKIE

    cat tmp/mailcap-$COOKIE > etc/mailcap
    rm -f tmp/mailcap-$COOKIE

  fi
fi

## BEGIN (HERE IS WHAT CAUSED THIS MESS):

## Add some reasonable default values for xdg-open to /etc/mailcap,
## since this is where many programs look for this information:
#
#if ! grep -q '# Sample xdg-open entries:' etc/mailcap 1> /dev/null 2> /dev/null ; then
#  echo "# Sample xdg-open entries:" >> etc/mailcap
#  echo >> etc/mailcap
#fi
#if ! grep -q 'audio/' etc/mailcap ; then
#  echo 'audio/*; /usr/bin/xdg-open %s' >> etc/mailcap
#  echo >> etc/mailcap
#fi
#if ! grep -q 'image/' etc/mailcap ; then
#  echo 'image/*; /usr/bin/xdg-open %s' >> etc/mailcap
#  echo >> etc/mailcap
#fi
#if ! grep -q 'application/msword' etc/mailcap ; then
#  echo 'application/msword; /usr/bin/xdg-open %s' >> etc/mailcap
#  echo >> etc/mailcap
#fi
#if ! grep -q 'application/pdf' etc/mailcap ; then
#  echo 'application/pdf; /usr/bin/xdg-open %s' >> etc/mailcap
#  echo >> etc/mailcap
#fi
#if ! grep -q 'application/postscript' etc/mailcap ; then
#  echo 'application/postscript ; /usr/bin/xdg-open %s' >> etc/mailcap
#  echo >> etc/mailcap
#fi
#if ! grep -q '#text/html' etc/mailcap ; then
#  echo '#text/html; /usr/bin/xdg-open %s ; copiousoutput' >> etc/mailcap
#  echo >> etc/mailcap
#fi

## END

