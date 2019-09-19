if [ -e /usr/share/icons/Adwaita/icon-theme.cache ]; then
  if [ -x /usr/bin/gtk-update-icon-cache ]; then
    /usr/bin/gtk-update-icon-cache /usr/share/icons/Adwaita 1> /dev/null 2> /dev/null
  fi
fi

