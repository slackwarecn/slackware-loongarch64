if [ ! -r etc/shells ]; then
  touch etc/shells
  chmod 644 etc/shells
fi
if ! grep -wq /bin/dash etc/shells ; then
  echo /bin/dash >> etc/shells
fi
# Compatibility for #!/bin/ash scripts:
if [ ! -r bin/ash ]; then
  ( cd bin ; ln -sf /bin/dash ash )
fi
if ! grep -wq /bin/ash etc/shells ; then
  echo /bin/ash >> etc/shells
fi
