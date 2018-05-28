# Slackware color ls profile script for /bin/csh-like shells.

# Set up LS_OPTIONS environment variable.
# This contains extra command line options to use with ls.
# The default ones are:
#  -F = show '/' for dirs, '*' for executables, etc.
#  -T 0 = don't trust tab spacing when formatting ls output.
#  -b = better support for special characters
setenv OPTIONS "-F -b -T 0"

# COLOR needs one of these arguments:
# 'auto' colorizes output to ttys, but not pipes.
# 'always' adds color characters to all output.
# 'never' shuts colorization off.
setenv COLOR auto

# This section shouldn't require any user adjustment since it is
# simply setting the LS_OPTIONS variable using the information
# already given above:
setenv LS_OPTIONS " $OPTIONS --color=$COLOR "
unsetenv COLOR
unsetenv OPTIONS

# Set up alias to use color ls by default:
alias ls '/bin/ls $LS_OPTIONS';
unsetenv noglob;

# Set up the LS_COLORS environment:
[ -f $HOME/.dir_colors ]
if ($status == 0) then
  eval `/bin/dircolors -c $HOME/.dir_colors`
endif
[ -f /etc/DIR_COLORS ] 
if ($status == 0) then
  eval `/bin/dircolors -c /etc/DIR_COLORS`
endif
[ ! -f $HOME/.dir_colors -a ! -f /etc/DIR_COLORS ]
if ($status == 0) then
  eval `/bin/dircolors -c`
endif

