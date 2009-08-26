if fgrep tcsh etc/shells 1> /dev/null 2> /dev/null ; then
 GOOD=y
else
 echo "/bin/tcsh" >> etc/shells
 echo "/bin/csh" >> etc/shells
fi
( cd bin ; rm -rf csh )
( cd bin ; ln -sf  tcsh csh )
