# Backup the old copy if we find one, move the new one in place
if [ -f bin/ksh ]; then
   mv bin/ksh bin/ksh.old
fi
mv bin/ksh.new bin/ksh
if [ -f bin/ksh.old ]; then
  rm -f bin/ksh.old
fi

# Add entries to /etc/shells if we need them
if [ ! -r etc/shells ] ; then
   touch etc/shells
   chmod 644 etc/shells
fi

if ! grep -q "/bin/ksh" etc/shells ; then
   echo "/bin/ksh" >> etc/shells
fi
