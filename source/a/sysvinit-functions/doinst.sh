( cd etc
  for dir in init.d rc0.d rc1.d rc2.d rc3.d rc4.d rc5.d rc6.d ; do
    if [ ! -L $dir -a -d $dir ]; then
      mv ${dir} ${dir}.bak
    fi
  done
)
( cd etc ; rm -rf init.d )
( cd etc ; ln -sf rc.d/init.d init.d )
( cd etc ; rm -rf rc0.d )
( cd etc ; ln -sf rc.d/rc0.d rc0.d )
( cd etc ; rm -rf rc1.d )
( cd etc ; ln -sf rc.d/rc1.d rc1.d )
( cd etc ; rm -rf rc2.d )
( cd etc ; ln -sf rc.d/rc2.d rc2.d )
( cd etc ; rm -rf rc3.d )
( cd etc ; ln -sf rc.d/rc3.d rc3.d )
( cd etc ; rm -rf rc4.d )
( cd etc ; ln -sf rc.d/rc4.d rc4.d )
( cd etc ; rm -rf rc5.d )
( cd etc ; ln -sf rc.d/rc5.d rc5.d )
( cd etc ; rm -rf rc6.d )
( cd etc ; ln -sf rc.d/rc6.d rc6.d )
