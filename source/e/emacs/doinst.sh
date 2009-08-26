# Vim ships a better (IMHO) version of ctags, and we don't want
# to overwrite it with this one.  If you really want emacs' ctags
# either copy or link it into place yourself, or remove the vim
# packages and reinstall emacs.  Besides, does anyone know/use
# *both* emacs and vi?  I'd think that would bring the universe
# to an end.  ;-)
if [ ! -e usr/bin/ctags ]; then
  cp -a usr/bin/ctags-emacs usr/bin/ctags
  cp -a usr/man/man1/ctags-emacs.1.gz usr/man/man1/ctags.1.gz
fi
