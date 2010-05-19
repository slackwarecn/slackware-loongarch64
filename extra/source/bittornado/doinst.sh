# Add bittorrent support to /etc/mailcap unless it's found there
# already (commented out, or not):
if ! grep application/x-bittorrent etc/mailcap 1> /dev/null 2> /dev/null ; then
  echo "application/x-bittorrent; /usr/bin/btdownloadxterm.sh '%s' ; " >> etc/mailcap
fi


# Add bittornado support to /etc/mailcap unless it's found there
# already (commented out, or not):
if ! grep application/x-bittorrent etc/mailcap 1> /dev/null 2> /dev/null ; then
  echo "application/x-bittorrent; /usr/bin/btdownloadxterm.sh '%s' ; " >> etc/mailcap
else
  # If it calls bittorrent-xterm, make btdownloadxterm.sh the default instead:
  if grep bittorrent-xterm etc/mailcap 1> /dev/null 2> /dev/null ; then
    sed -i -e 's/bittorrent-xterm/btdownloadxterm.sh/g' etc/mailcap
  fi
fi
