# Run this script in the root of the skeleton tree
# to re-create the required device nodes
mkdir -p dev
mknod -m 600 dev/arp c 16 1
mkdir -p dev
mknod -m 644 dev/atibm c 10 3
mkdir -p dev
mknod -m 644 dev/audio c 14 4
mkdir -p dev
mknod -m 644 dev/audio1 c 14 20
mkdir -p dev
mknod -m 640 dev/aztcd b 29 0
mkdir -p dev
mknod -m 640 dev/bpcd b 41 0
mkdir -p dev
mknod -m 640 dev/cdu535 b 24 0
mkdir -p dev
mknod -m 640 dev/cm206cd b 32 0
mkdir -p dev
mknod -m 600 dev/console c 5 1
mkdir -p dev
mknod -m 640 dev/cua0 c 5 64
mkdir -p dev
mknod -m 640 dev/cua1 c 5 65
mkdir -p dev
mknod -m 640 dev/cua2 c 5 66
mkdir -p dev
mknod -m 640 dev/cua3 c 5 67
mkdir -p dev
mknod -m 640 dev/cua4 c 5 68
mkdir -p dev
mknod -m 640 dev/eda b 36 0
mkdir -p dev
mknod -m 640 dev/eda1 b 36 1
mkdir -p dev
mknod -m 640 dev/eda2 b 36 2
mkdir -p dev
mknod -m 640 dev/eda3 b 36 3
mkdir -p dev
mknod -m 640 dev/eda4 b 36 4
mkdir -p dev
mknod -m 640 dev/eda5 b 36 5
mkdir -p dev
mknod -m 640 dev/eda6 b 36 6
mkdir -p dev
mknod -m 640 dev/eda7 b 36 7
mkdir -p dev
mknod -m 640 dev/eda8 b 36 8
mkdir -p dev
mknod -m 640 dev/eda9 b 36 9
mkdir -p dev
mknod -m 640 dev/fd0 b 2 0
mkdir -p dev
mknod -m 640 dev/fd0h1200 b 2 8
mkdir -p dev
mknod -m 640 dev/fd0h1440 b 2 40
mkdir -p dev
mknod -m 640 dev/fd0u1440 b 2 28
mkdir -p dev
mknod -m 660 dev/fd0u1680 b 2 44
mkdir -p dev
mknod -m 660 dev/fd0u1722 b 2 60
mkdir -p dev
mknod -m 640 dev/fd1 b 2 1
mkdir -p dev
mknod -m 640 dev/fd1h1200 b 2 9
mkdir -p dev
mknod -m 640 dev/fd1h1440 b 2 41
mkdir -p dev
mknod -m 640 dev/fd1u1440 b 2 29
mkdir -p dev
mknod -m 644 dev/full c 1 7
mkdir -p dev
mknod -m 640 dev/gscd0 b 16 0
mkdir -p dev
mknod -m 660 dev/hda b 3 0
mkdir -p dev
mknod -m 660 dev/hdb b 3 64
mkdir -p dev
mknod -m 660 dev/hdc b 22 0
mkdir -p dev
mknod -m 660 dev/hdd b 22 64
mkdir -p dev
mknod -m 660 dev/hde b 33 0
mkdir -p dev
mknod -m 660 dev/hdf b 33 64
mkdir -p dev
mknod -m 660 dev/hdg b 34 0
mkdir -p dev
mknod -m 660 dev/hdh b 34 64
mkdir -p dev
mknod -m 660 dev/hdi b 56 0
mkdir -p dev
mknod -m 660 dev/hdj b 56 64
mkdir -p dev
mknod -m 660 dev/hdk b 57 0
mkdir -p dev
mknod -m 660 dev/hdl b 57 64
mkdir -p dev
mknod -m 660 dev/hdm b 88 0
mkdir -p dev
mknod -m 660 dev/hdn b 88 64
mkdir -p dev
mknod -m 660 dev/hdo b 89 0
mkdir -p dev
mknod -m 660 dev/hdp b 89 64
mkdir -p dev
mknod -m 660 dev/hdq b 90 0
mkdir -p dev
mknod -m 660 dev/hdr b 90 64
mkdir -p dev
mknod -m 660 dev/hds b 91 0
mkdir -p dev
mknod -m 660 dev/hdt b 91 64
mkdir -p dev
mknod -m 600 dev/icmp c 18 2
mkdir -p dev/inet
mknod -m 644 dev/inet/egp c 30 37
mkdir -p dev/inet
mknod -m 644 dev/inet/ggp c 30 34
mkdir -p dev/inet
mknod -m 644 dev/inet/icmp c 30 33
mkdir -p dev/inet
mknod -m 644 dev/inet/idp c 30 40
mkdir -p dev/inet
mknod -m 644 dev/inet/ip c 30 32
mkdir -p dev/inet
mknod -m 644 dev/inet/ipip c 30 35
mkdir -p dev/inet
mknod -m 644 dev/inet/pup c 30 38
mkdir -p dev/inet
mknod -m 644 dev/inet/rawip c 30 41
mkdir -p dev/inet
mknod -m 644 dev/inet/tcp c 30 36
mkdir -p dev/inet
mknod -m 644 dev/inet/udp c 30 39
mkdir -p dev
mknod -m 644 dev/inportbm c 10 2
mkdir -p dev/input
mknod -m 644 dev/input/event0 c 13 64
mkdir -p dev/input
mknod -m 644 dev/input/js0 c 13 0
mkdir -p dev/input
mknod -m 660 dev/input/keyboard c 10 150
mkdir -p dev/input
mknod -m 644 dev/input/mice c 13 63
mkdir -p dev/input
mknod -m 660 dev/input/mouse c 10 149
mkdir -p dev/input
mknod -m 644 dev/input/mouse0 c 13 32
mkdir -p dev
mknod -m 600 dev/ip c 18 1
mkdir -p dev
mknod -m 640 dev/kmem c 1 2
mkdir -p dev
mknod -m 640 dev/lmscd b 24 0
mkdir -p dev
mknod -m 644 dev/logibm c 10 0
mkdir -p dev
mknod -m 660 dev/loop0 b 7 0
mkdir -p dev
mknod -m 660 dev/loop1 b 7 1
mkdir -p dev
mknod -m 660 dev/loop3 b 7 3
mkdir -p dev
mknod -m 660 dev/loop4 b 7 4
mkdir -p dev
mknod -m 640 dev/lp0 c 6 0
mkdir -p dev
mknod -m 640 dev/mcd b 23 0
mkdir -p dev
mknod -m 640 dev/mcdx0 b 20 0
mkdir -p dev
mknod -m 640 dev/mcdx1 b 20 1
mkdir -p dev
mknod -m 660 dev/md0 b 9 0
mkdir -p dev
mknod -m 660 dev/md1 b 9 1
mkdir -p dev
mknod -m 660 dev/md10 b 9 10
mkdir -p dev
mknod -m 660 dev/md11 b 9 11
mkdir -p dev
mknod -m 660 dev/md12 b 9 12
mkdir -p dev
mknod -m 660 dev/md13 b 9 13
mkdir -p dev
mknod -m 660 dev/md14 b 9 14
mkdir -p dev
mknod -m 660 dev/md15 b 9 15
mkdir -p dev
mknod -m 660 dev/md2 b 9 2
mkdir -p dev
mknod -m 660 dev/md3 b 9 3
mkdir -p dev
mknod -m 660 dev/md4 b 9 4
mkdir -p dev
mknod -m 660 dev/md5 b 9 5
mkdir -p dev
mknod -m 660 dev/md6 b 9 6
mkdir -p dev
mknod -m 660 dev/md7 b 9 7
mkdir -p dev
mknod -m 660 dev/md8 b 9 8
mkdir -p dev
mknod -m 660 dev/md9 b 9 9
mkdir -p dev
mknod -m 640 dev/mem c 1 1
mkdir -p dev
mknod -m 640 dev/nrft0 c 27 4
mkdir -p dev
mknod -m 640 dev/nst0 c 9 128
mkdir -p dev
mknod -m 640 dev/nst1 c 9 129
mkdir -p dev
mknod -m 644 dev/null c 1 3
mkdir -p dev
mknod -m 640 dev/optcd0 b 17 0
mkdir -p dev
mknod -m 640 dev/par0 c 6 0
mkdir -p dev
mknod -m 640 dev/par1 c 6 1
mkdir -p dev
mknod -m 640 dev/par2 c 6 2
mkdir -p dev
mknod -m 660 dev/parport0 c 99 0
mkdir -p dev
mknod -m 660 dev/parport1 c 99 1
mkdir -p dev
mknod -m 660 dev/parport2 c 99 2
mkdir -p dev
mknod -m 660 dev/parport3 c 99 3
mkdir -p dev
mknod -m 640 dev/pcd0 b 46 0
mkdir -p dev
mknod -m 640 dev/pcd1 b 46 1
mkdir -p dev
mknod -m 640 dev/pcd2 b 46 2
mkdir -p dev
mknod -m 640 dev/pcd3 b 46 3
mkdir -p dev
mknod -m 640 dev/pda b 45 0
mkdir -p dev
mknod -m 640 dev/pda1 b 45 1
mkdir -p dev
mknod -m 640 dev/pda2 b 45 2
mkdir -p dev
mknod -m 640 dev/pda3 b 45 3
mkdir -p dev
mknod -m 640 dev/pda4 b 45 4
mkdir -p dev
mknod -m 640 dev/pda5 b 45 5
mkdir -p dev
mknod -m 640 dev/pda6 b 45 6
mkdir -p dev
mknod -m 640 dev/pf0 b 47 0
mkdir -p dev
mknod -m 640 dev/pf1 b 47 1
mkdir -p dev
mknod -m 640 dev/pf2 b 47 2
mkdir -p dev
mknod -m 640 dev/pf3 b 47 3
mkdir -p dev
mknod -m 640 dev/port c 1 4
mkdir -p dev
mknod -m 644 dev/psaux c 10 1
mkdir -p dev
mknod -m 644 dev/ptyp0 c 2 0
mkdir -p dev
mknod -m 644 dev/ptyp1 c 2 1
mkdir -p dev
mknod -m 644 dev/ptyp2 c 2 2
mkdir -p dev
mknod -m 644 dev/ptyp3 c 2 3
mkdir -p dev
mknod -m 644 dev/ptyp4 c 2 4
mkdir -p dev
mknod -m 644 dev/ptyp5 c 2 5
mkdir -p dev
mknod -m 644 dev/ptyp6 c 2 6
mkdir -p dev
mknod -m 644 dev/ptyp7 c 2 7
mkdir -p dev
mknod -m 644 dev/ptyp8 c 2 8
mkdir -p dev
mknod -m 640 dev/ram0 b 1 0
mkdir -p dev
mknod -m 640 dev/ram1 b 1 1
mkdir -p dev
mknod -m 644 dev/random c 1 8
mkdir -p dev
mknod -m 640 dev/rft0 c 27 0
mkdir -p dev
mknod -m 640 dev/rmt16 c 12 8
mkdir -p dev
mknod -m 640 dev/rmt8 c 12 6
mkdir -p dev
mknod -m 640 dev/sbpcd b 25 0
mkdir -p dev
mknod -m 640 dev/sbpcd0 b 25 0
mkdir -p dev
mknod -m 640 dev/sbpcd1 b 25 1
mkdir -p dev
mknod -m 640 dev/scd0 b 11 0
mkdir -p dev
mknod -m 640 dev/scd1 b 11 1
mkdir -p dev
mknod -m 640 dev/scd2 b 11 2
mkdir -p dev
mknod -m 640 dev/scd3 b 11 3
mkdir -p dev
mknod -m 640 dev/scd4 b 11 4
mkdir -p dev
mknod -m 600 dev/sga c 21 0
mkdir -p dev
mknod -m 600 dev/sgb c 21 1
mkdir -p dev
mknod -m 600 dev/sgc c 21 2
mkdir -p dev
mknod -m 600 dev/sgd c 21 3
mkdir -p dev
mknod -m 600 dev/sge c 21 4
mkdir -p dev
mknod -m 600 dev/sgf c 21 5
mkdir -p dev
mknod -m 600 dev/sgg c 21 6
mkdir -p dev
mknod -m 600 dev/sgh c 21 7
mkdir -p dev
mknod -m 640 dev/sjcd b 18 0
mkdir -p dev
mknod -m 600 dev/socket c 16 0
mkdir -p dev
mknod -m 644 dev/socksys c 30 0
mkdir -p dev
mknod -m 640 dev/sonycd b 15 0
mkdir -p dev
mknod -m 644 dev/spx c 30 1
mkdir -p dev
mknod -m 640 dev/sr0 b 11 0
mkdir -p dev
mknod -m 640 dev/sr1 b 11 1
mkdir -p dev
mknod -m 640 dev/sr2 b 11 2
mkdir -p dev
mknod -m 640 dev/sr3 b 11 3
mkdir -p dev
mknod -m 640 dev/sr4 b 11 4
mkdir -p dev
mknod -m 640 dev/st0 c 9 0
mkdir -p dev
mknod -m 640 dev/st1 c 9 1
mkdir -p dev
mknod -m 640 dev/tape-d c 12 136
mkdir -p dev
mknod -m 640 dev/tape-reset c 12 255
mkdir -p dev
mknod -m 600 dev/tcp c 18 3
mkdir -p dev
mknod -m 644 dev/tty c 5 0
mkdir -p dev
mknod -m 600 dev/tty0 c 4 0
mkdir -p dev
mknod -m 700 dev/tty1 c 4 1
mkdir -p dev
mknod -m 600 dev/tty2 c 4 2
mkdir -p dev
mknod -m 600 dev/tty3 c 4 3
mkdir -p dev
mknod -m 600 dev/tty4 c 4 4
mkdir -p dev
mknod -m 600 dev/tty5 c 4 5
mkdir -p dev
mknod -m 600 dev/tty6 c 4 6
mkdir -p dev
mknod -m 644 dev/tty7 c 4 7
mkdir -p dev
mknod -m 644 dev/tty8 c 4 8
mkdir -p dev
mknod -m 644 dev/tty9 c 4 9
mkdir -p dev
mknod -m 640 dev/ttyS0 c 4 64
mkdir -p dev
mknod -m 640 dev/ttyS1 c 4 65
mkdir -p dev
mknod -m 640 dev/ttyS2 c 4 66
mkdir -p dev
mknod -m 640 dev/ttyS3 c 4 67
mkdir -p dev
mknod -m 640 dev/ttyS4 c 4 68
mkdir -p dev
mknod -m 644 dev/ttyp0 c 3 0
mkdir -p dev
mknod -m 700 dev/ttyp1 c 3 1
mkdir -p dev
mknod -m 700 dev/ttyp2 c 3 2
mkdir -p dev
mknod -m 600 dev/ttyp3 c 3 3
mkdir -p dev
mknod -m 644 dev/ttyp4 c 3 4
mkdir -p dev
mknod -m 644 dev/ttyp5 c 3 5
mkdir -p dev
mknod -m 644 dev/ttyp6 c 3 6
mkdir -p dev
mknod -m 644 dev/ttyp7 c 3 7
mkdir -p dev
mknod -m 644 dev/ttyp8 c 3 8
mkdir -p dev
mknod -m 600 dev/udp c 18 4
mkdir -p dev
mknod -m 600 dev/unix c 17 0
mkdir -p dev
mknod -m 644 dev/urandom c 1 9
mkdir -p dev
mknod -m 644 dev/zero c 1 5
