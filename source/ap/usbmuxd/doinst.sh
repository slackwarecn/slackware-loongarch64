# Make sure that the usbmux user exists with the GID for plugdev access:
if ! grep -q "^usbmux:" etc/passwd ; then
  echo "usbmux:x:52:83:User for usbmux daemon:/var/empty:/bin/false" >> etc/passwd
fi

