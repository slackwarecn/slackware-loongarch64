if ! grep -q tcsh etc/shells 2> /dev/null ; then
 echo "/bin/tcsh" >> etc/shells
 echo "/bin/csh" >> etc/shells
fi
