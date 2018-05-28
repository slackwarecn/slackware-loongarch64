# Slackware color ls profile script for /bin/sh-like shells.

# Set up LS_OPTIONS environment variable.
# This contains extra command line options to use with ls.
# The default ones are:
#  -F = show '/' for dirs, '*' for executables, etc.
#  -T 0 = don't trust tab spacing when formatting ls output.
#  -b = better support for special characters
OPTIONS="-F -b -T 0"

# COLOR needs one of these arguments:
# 'auto' colorizes output to ttys, but not pipes.
# 'always' adds color characters to all output.
# 'never' shuts colorization off.
COLOR=auto


# This section shouldn't require any user adjustment since it is
# simply setting the LS_OPTIONS variable using the information
# already given above:
LS_OPTIONS="$OPTIONS --color=$COLOR";
export LS_OPTIONS;
unset COLOR
unset OPTIONS

# Set up aliases to use color ls by default:
if [ "$SHELL" = "/bin/zsh" ] ; then
  # By default, zsh doesn't split parameters into separate words
  # when it encounters whitespace.  The '=' flag will fix this.
  # see zshexpn(1) man-page regarding SH_WORD_SPLIT.
  alias ls='/bin/ls ${=LS_OPTIONS}'
else
  alias ls='/bin/ls $LS_OPTIONS'
fi

# Set up the LS_COLORS environment:
if [ -f $HOME/.dir_colors ]; then
  eval `/bin/dircolors -b $HOME/.dir_colors`
elif [ -f /etc/DIR_COLORS ]; then
  eval `/bin/dircolors -b /etc/DIR_COLORS`
else
  eval `/bin/dircolors -b`
fi

