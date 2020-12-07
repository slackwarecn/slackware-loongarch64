if [ -e usr/share/icons/elementary-xfce/icon-theme.cache ]; then
  if [ -x /usr/bin/gtk-update-icon-cache ]; then
    /usr/bin/gtk-update-icon-cache usr/share/icons/elementary-xfce>/dev/null 2>&1
  fi
fi

if [ -e usr/share/icons/elementary-xfce-dark/icon-theme.cache ]; then
  if [ -x /usr/bin/gtk-update-icon-cache ]; then
    /usr/bin/gtk-update-icon-cache usr/share/icons/elementary-xfce-dark>/dev/null 2>&1
  fi
fi

if [ -e usr/share/icons/elementary-xfce-darker/icon-theme.cache ]; then
  if [ -x /usr/bin/gtk-update-icon-cache ]; then
    /usr/bin/gtk-update-icon-cache usr/share/icons/elementary-xfce-darker>/dev/null 2>&1
  fi
fi

if [ -e usr/share/icons/elementary-xfce-darkest/icon-theme.cache ]; then
  if [ -x /usr/bin/gtk-update-icon-cache ]; then
    /usr/bin/gtk-update-icon-cache usr/share/icons/elementary-xfce-darkest>/dev/null 2>&1
  fi
fi

