#
# Makefile for unarj under Linux
# by Arrigo Triulzi ({a.triulzi,agbt}@{imperial,ic}.ac.uk)
#

CC = gcc
CFLAGS = -O2 -DUNIX
INSTALLDIR=/usr/bin

unarj: unarj.o decode.o environ.o
	gcc $(CFLAGS) -o unarj unarj.o decode.o environ.o

clean:
	rm -f core unarj *.o *.out

install:
	cp unarj $(INSTALLDIR)

unarj.o: unarj.c unarj.h Makefile
environ.o:  environ.c unarj.h Makefile
decode.o:   decode.c unarj.h Makefile
