# Add bittorrent support to /etc/mailcap unless it's found there
# already (commented out, or not):
if ! grep application/x-bittorrent etc/mailcap 1> /dev/null 2> /dev/null ; then
  echo "application/x-bittorrent; /usr/bin/bittorrent-xterm '%s' ; " >> etc/mailcap
else
  # If it calls btdownloadxterm.sh, make bittorrent-xterm the default instead:
  if grep btdownloadxterm etc/mailcap 1> /dev/null 2> /dev/null ; then
    sed -i -e 's/btdownloadxterm.sh/bittorrent-xterm/g' etc/mailcap
  fi
fi
