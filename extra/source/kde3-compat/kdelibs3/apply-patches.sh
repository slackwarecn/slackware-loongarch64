zcat $CWD/kdelibs-utempter.diff.gz | patch -p1 --verbose --backup --suffix=.orig || exit 1
zcat $CWD/kdelibs.inotify.diff.gz | patch -p1 --verbose --backup --suffix=.orig || exit 1
zcat $CWD/kdelibs.no.inotify.externs.diff.gz | patch -p1 --verbose --backup --suffix=.orig || exit 1
