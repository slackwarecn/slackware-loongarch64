### LoongArch Slackware current bootstrap

> BBS: https://bbs.loongarch.org/d/95-loongarch-slackware-current-bootstrap


#### tag:0.5 slackware-current-bootstrap-2023.07.06-loong64

| package | branch | commit hash | url |
| ---- | ---- | ---- | ---- |
| binutils | 2.40 | release | https://sourceware.org/git/binutils-gdb.git |
| gcc | 13.1.0 | release | git://gcc.gnu.org/git/gcc.git |
| glibc | 2.37 | release | https://sourceware.org/git/glibc.git |
| linux | 6.4.0 | release | https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.4.0.tar.gz |

##### Update notes:

* Upgrade 20230706 
* Add KDE desktop support:

`machine has an independent graphics card, KDE is recommended, otherwise XFCE is recommended.`

* Slackwareloong mirrors:
```
https://mirrors.wsyu.edu.cn/slackwareloong/
https://mirrors.nju.edu.cn/slackwareloong/
```

* Supports `3A5000`/`3A5000+7A1000`/`3A5000+7A2000` machines(iso version >= 20230626)


#### tag:0.4 slackware-current-bootstrap-2023.07.01-loong64

| package | branch | commit hash | url |
| ---- | ---- | ---- | ---- |
| binutils | 2.40 | release | https://sourceware.org/git/binutils-gdb.git |
| gcc | 13.1.0 | release | git://gcc.gnu.org/git/gcc.git |
| glibc | 2.37 | release | https://sourceware.org/git/glibc.git |
| linux | 6.4.0 | release | https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.4.0.tar.gz |

* Add mirrors:
```
https://mirrors.wsyu.edu.cn/slackwareloong/
https://mirrors.nju.edu.cn/slackwareloong/
```

* Supports 3A5000/3A5000+7A1000/3A5000+7A2000 machines(iso version >= 20230626)


#### tag:0.3 slackware-current-bootstrap-2022.10.12-loong64

| package | branch | commit hash | url |
| ---- | ---- | ---- | ---- |
| binutils | 2.39.50.20221012 | 182421c | https://sourceware.org/git/binutils-gdb.git |
| gcc | 13.0.0 20221012 | 11c72f2 | git://gcc.gnu.org/git/gcc.git |
| glibc | 2.36.9000 | 264db94 | https://sourceware.org/git/glibc.git |
| linux | 6.0.1 | release | https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.0.1.tar.gz |

* compiler toolchain: supported  new relocations types.
* Update e_flags for new relocations. 
```
0 root:~ # readelf -h /bin/bash | grep Flags
  Flags:    0x43, DOUBLE-FLOAT, OBJ-v1
```


#### tag:0.2 slackware-current-bootstrap-2022.09.05-loong64

| package | branch | commit hash | url |
| ---- | ---- | ---- | ---- |
| binutils | 2.39.50.20220905 | 06c00d5feaf78869b42c28f9b5519c922a6dc765 | https://sourceware.org/git/binutils-gdb.git |
| gcc | 13.0.0 20220905 | 092763fd0c069f3a7c05a65238d3815e8daab76b | git://gcc.gnu.org/git/gcc.git |
| glibc | 2.36.9000 | 930993921f2f381b545ea1b1f2d9c534b2b72b08 | https://sourceware.org/git/glibc.git |
| linux | 6.0-rc4 | release | https://git.kernel.org/torvalds/t/linux-6.0-rc4.tar.gz |

* compiler toolchain: supported new relocations types


#### tag:0.1 slackware-current-bootstrap-2022.07.08-loongarch64

| package | branch | commit hash | url |
| ---- | ---- | ---- | ---- |
| binutils | 2.38 release | release | https://ftp.gnu.org/gnu/binutils/binutils-2.38.tar.lz |
| gcc | 12.1.0 release | release | https://ftp.gnu.org/gnu/gcc/gcc-12.1.0/gcc-12.1.0.tar.xz |
| glibc | loongarch_2_36_dev_v4 | 29a3ed2ec825b72d0def7cb51b3998615abf8c6b | https://github.com/loongson/glibc.git |
| linux | 5.19.0-rc4 | 78c36a0c87b9d55a3289c44ab691e7940619fcc1 | https://github.com/loongson/linux.git |
| libffi | loongarch-3_4_2 | 70602040e7a319ad4131aad422d59a493bc65f18 | https://github.com/loongson/libffi.git |


