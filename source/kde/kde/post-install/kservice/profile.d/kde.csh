#!/bin/csh
# KDE additions:
if ( ! $?KDEDIRS ) then
    setenv KDEDIRS /usr
endif

# Add KDE paths if they exist:
if ( -d /usr/lib/kf5 ) then
    setenv PATH ${PATH}:/usr/lib/kf5
endif
if ( -d /usr/lib/kde4/libexec ) then
    setenv PATH ${PATH}:/usr/lib/kde4/libexec
endif

# Add /etc/kde/xdg to $XDG_CONFIG_DIRS:
if ( $?XDG_CONFIG_DIRS ) then
    setenv XDG_CONFIG_DIRS ${XDG_CONFIG_DIRS}:/etc/kde/xdg
else
    setenv XDG_CONFIG_DIRS /etc/xdg:/etc/kde/xdg
endif

# Commented out, since PAM should take care of this:
#if ( ! $?XDG_RUNTIME_DIR ) then
#    # Using /run/user would be more in line with XDG specs, but in that case
#    # we should mount /run as tmpfs and add this to the Slackware rc scripts:
#    # mkdir /run/user ; chmod 1777 /run/user
#    # setenv XDG_RUNTIME_DIR /run/user/$USER
#    setenv XDG_RUNTIME_DIR /tmp/xdg-runtime-$USER
#    mkdir -p $XDG_RUNTIME_DIR
#    chown $USER $XDG_RUNTIME_DIR
#    chmod 700 $XDG_RUNTIME_DIR
#endif
