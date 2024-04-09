chroot . /usr/bin/mktexlsr 1>/dev/null 2>/dev/null
printf "y\n" | chroot . /usr/bin/updmap-sys --syncwithtrees 1>/dev/null 2>/dev/null
chroot . /usr/bin/updmap-sys 1>/dev/null 2>/dev/null
chroot . /usr/bin/fmtutil-sys --all 1>/dev/null 2>/dev/null

if [ -x /usr/bin/install-info -a -d usr/info ]; then
  ( cd usr/info
    rm -f dir
    for i in *.info*; do /usr/bin/install-info $i dir 2>/dev/null; done
  )
fi

