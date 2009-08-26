if [ -x /usr/bin/install-info ] ; then
  install-info --info-dir=/usr/info /usr/info/diff.info.gz 2>/dev/null
elif ! grep "diff3" usr/info/dir 1> /dev/null 2> /dev/null ; then
cat << EOF >> usr/info/dir

GNU packages
* Diff: (diff).                 Comparing and merging files.

Individual utilities
* cmp: (diff)Invoking cmp.                      Compare 2 files byte by byte.
* diff3: (diff)Invoking diff3.                  Compare 3 files line by line.
* diff: (diff)Invoking diff.                    Compare 2 files line by line.
* patch: (diff)Invoking patch.                  Apply a patch to a file.
* sdiff: (diff)Invoking sdiff.                  Merge 2 files side-by-side.
EOF
fi
