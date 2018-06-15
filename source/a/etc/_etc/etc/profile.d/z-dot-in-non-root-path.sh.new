#!/bin/sh
# Traditionally Slackware has included '.' at the end of the non-root
# $PATH, and kept this behavior long after it had been dropped elsewhere
# due to the relatively low attack risk by having it at (or near) the
# end of the $PATH.  But times have changed, and having this as a default
# violates POLA (principle of least astonishment) just like removing it
# back in the early 90s would have.  So, by default this script is not
# enabled.  If you'd like '.' back at the end of your $PATH for non-root
# users systemwide, make this script executable.  A better choice is
# probably to leave it off and let individual users decide to add it
# in their local profile scripts if they want it.  Even better is just
# to start programs in '.' with ./program, like most of us have been
# doing for years.

# For non-root users, add the current directory to the search path:
if [ ! "`id -u`" = "0" ]; then
 PATH="$PATH:."
fi

