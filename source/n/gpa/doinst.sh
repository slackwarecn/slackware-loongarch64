# [note after changing relative paths to absolute ones]
#
# Sorry, but things like this can't be done from the
# installer, or must be deferred until after everything
# is installed (i.e. scripted in /var/log/setup)

if [ -x /usr/bin/update-desktop-database ]; then
  /usr/bin/update-desktop-database &> /dev/null
fi

if [ -x /usr/bin/gtk-update-icon-cache ]; then
  /gtk-update-icon-cache -f -t /usr/share/icons/hicolor &> /dev/null
fi
