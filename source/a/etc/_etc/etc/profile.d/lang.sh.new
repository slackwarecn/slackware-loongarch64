#!/bin/sh
# Set the system locale.  (no, we don't have a menu for this ;-)
# For a list of locales which are supported by this machine, type:
#   locale -a

# en_US.UTF-8 is the Slackware default locale.  If you're looking for
# a different UTF-8 locale, be aware that some of them do not include
# UTF-8 or utf8 in the name.  To test if a locale is UTF-8, use this
# command:
#
# LANG=<locale> locale -k charmap
#
# UTF-8 locales will include "UTF-8" in the output.
export LANG=en_US.UTF-8

# 'C' is the old Slackware (and UNIX) default, which is 127-bit ASCII
# with a charmap setting of ANSI_X3.4-1968.  These days, it's better to
# use en_US.UTF-8 or another modern $LANG setting (or at least en_US)
# to support extended character sets.
#export LANG=C

# Non-UTF-8 options for en_US:
#export LANG=en_US
#export LANG=en_US.ISO8859-1

# One side effect of the newer locales is that the sort order
# is no longer according to ASCII values, so the sort order will
# change in many places.  Since this isn't usually expected and
# can break scripts, we'll stick with traditional ASCII sorting.
# If you'd prefer the sort algorithm that goes with your $LANG
# setting, comment this out.
export LC_COLLATE=C

# End of /etc/profile.d/lang.sh

