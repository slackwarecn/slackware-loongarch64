# /etc/csh.login: This file contains login defaults used by csh and tcsh.

# Set up some environment variables:
if ($?prompt) then
	umask 022
	set cdpath = ( /var/spool )
	set notify
	set history = 100
	setenv MINICOM "-c on"
	setenv HOSTNAME "`cat /etc/HOSTNAME`"
	setenv LESS "-M"
	setenv LESSOPEN "|lesspipe.sh %s"
	set path = ( $path /usr/games )
endif

# If the user doesn't have a .inputrc, use the one in /etc.
if (! -r "$HOME/.inputrc") then
	setenv INPUTRC /etc/inputrc
endif

# I had problems with the backspace key installed by 'tset', but you might want
# to try it anyway instead of the section below it.  I think with the right
# /etc/termcap it would work.
# eval `tset -sQ "$term"`

# Set TERM to linux for unknown type or unset variable:
if ! $?TERM setenv TERM linux
if ("$TERM" == "") setenv TERM linux
if ("$TERM" == "unknown") setenv TERM linux

# Set the default shell prompt:
set prompt = "%n@%m:%~%# "

# Notify user of incoming mail.  This can be overridden in the user's
# local startup file (~/.login)
biff y >& /dev/null

# Set an empty MANPATH if none exists (this prevents some profile.d scripts
# from exiting from trying to access an unset variable):
if ! $?MANPATH setenv MANPATH ""

# Append any additional csh scripts found in /etc/profile.d/:
[ -d /etc/profile.d ]
if ($status == 0) then
        set nonomatch
        foreach file ( /etc/profile.d/*.csh )
                [ -x $file ]
                if ($status == 0) then
                        source $file
                endif
        end
        unset file nonomatch
endif

