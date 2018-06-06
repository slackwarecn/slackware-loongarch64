#!/bin/sh

# Remove extra whitespace
crunch() {
  while read line ; do
    echo $line
  done
}

echo
echo "******* Welcome to the network supplemental disk! *******"
echo

# main loop:
while [ 0 ]; do

echo "-- Press [enter] to automatically probe for all network cards, or switch"
echo "   to a different console and use 'modprobe' to load the modules manually."
echo "-- To skip probing some modules (in case of hangs), enter them after an S:"
echo "   S eepro100 ne2k-pci"
echo "-- To probe only certain modules, enter them after a P like this:"
echo "   P 3c503 3c505 3c507"
echo "-- To get a list of network modules, enter an L."
echo "-- To skip the automatic probe entirely, enter a Q now."
echo

# Clear "card found" flag:
rm -f /cardfound

echo -n "network> "
read INPUT;
echo

if [ "`echo $INPUT | crunch | cut -f 1 -d ' '`" = "L" \
     -o "`echo $INPUT | crunch | cut -f 1 -d ' '`" = "l" ]; then
  echo "Available network modules:"
  for file in /lib/modules/`uname -r`/kernel/drivers/net/* /lib/modules/`uname -r`/kernel/arch/i386/kernel/* /lib/modules/`uname -r`/kernel/drivers/pnp/* ; do
    if [ -r $file ]; then
      OUTPUT=`basename $file .gz`
      OUTPUT=`basename $OUTPUT .o`
      echo -n "$OUTPUT "
    fi
  done
  echo
  echo
  continue
fi

if [ ! "$INPUT" = "q" -a ! "$INPUT" = "Q"  \
     -a ! "`echo $INPUT | crunch | cut -f 1 -d ' '`" = "P" \
     -a ! "`echo $INPUT | crunch | cut -f 1 -d ' '`" = "p" ]; then
  echo "Probing for PCI/EISA network cards:"
  for card in \
    3c59x acenic de4x5 dgrs eepro100 e1000 e1000e e100 epic100 hp100 ne2k-pci olympic pcnet32 rcpci 8139too 8139cp tulip via-rhine r8169 atl1e sktr yellowfin tg3 dl2k ns83820 \
    ; do
    SKIP=""
    if [ "`echo $INPUT | crunch | cut -f 1 -d ' '`" = "S" \
         -o "`echo $INPUT | crunch | cut -f 1 -d ' '`" = "s" ]; then
      for nogood in `echo $INPUT | crunch | cut -f 2- -d ' '` ; do
        if [ "$card" = "$nogood" ]; then
          SKIP=$card
        fi
      done
    fi
    if [ "$SKIP" = "" ]; then
      echo "Probing for card using the $card module..."
      modprobe $card 2> /dev/null
      grep -q eth0 /proc/net/dev
      if [ $? = 0 ]; then
        echo
        echo "SUCCESS: found card using $card protocol -- modules loaded."
        echo "$card" > /cardfound
        echo
        break
      else
        modprobe -r $card 2> /dev/null
      fi
    else
      echo "Skipping module $card..."
    fi
  done
  echo
  if [ ! -r /cardfound ]; then
    # Don't probe for com20020... it loads on any machine with or without the card.
    echo "Probing for MCA, ISA, and other PCI network cards:"
    # removed because it needs an irq parameter: arlan
    # tainted, no autoprobe: (arcnet) com90io com90xx
    for card in depca ibmtr 3c501 3c503 3c505 3c507 3c509 3c515 ac3200 \
      acenic at1700 cosa cs89x0 de4x5 de600 \
      de620 e2100 eepro eexpress es3210 eth16i ewrk3 fmv18x forcedeth hostess_sv11 \
      hp-plus hp lne390 ne3210 ni5010 ni52 ni65 sb1000 sealevel smc-ultra \
      sis900 smc-ultra32 smc9194 wd ; do 
      SKIP=""
      if [ "`echo $INPUT | crunch | cut -f 1 -d ' '`" = "S" \
           -o "`echo $INPUT | crunch | cut -f 1 -d ' '`" = "s" ]; then
        for nogood in `echo $INPUT | crunch | cut -f 2- -d ' '` ; do
          if [ "$card" = "$nogood" ]; then
            SKIP=$card
          fi
        done
      fi
      if [ "$SKIP" = "" ]; then
        echo "Probing for card using the $card module..."
        modprobe $card 2> /dev/null
        grep -q eth0 /proc/net/dev
        if [ $? = 0 ]; then
          echo
          echo "SUCCESS: found card using $card protocol -- modules loaded."
          echo "$card" > /cardfound
          echo
          break
        else
          modprobe -r $card 2> /dev/null
        fi
      else
        echo "Skipping module $card..."
      fi
    done
    echo
  fi
  if [ ! -r /cardfound ]; then
    echo "Sorry, but no network card was detected.  Some cards (like non-PCI"
    echo "NE2000s) must be supplied with the I/O address to use.  If you have"
    echo "an NE2000, you can switch to another console (Alt-F2), log in, and"
    echo "load it with a command like this:"
    echo
    echo "  modprobe ne io=0x360"
    echo
  fi
elif [ "`echo $INPUT | crunch | cut -f 1 -d ' '`" = "P" \
       -o "`echo $INPUT | crunch | cut -f 1 -d ' '`" = "p" ]; then
  echo "Probing for a custom list of modules:"
  for card in `echo $INPUT | crunch | cut -f 2- -d ' '` ; do
    echo "Probing for card using the $card module..."
    modprobe $card 2> /dev/null
    grep -q eth0 /proc/net/dev
    if [ $? = 0 ]; then
      echo
      echo "SUCCESS: found card using $card protocol -- modules loaded."
      echo "$card" > /cardfound
      echo
      break
    else
      modprobe -r $card 2> /dev/null
    fi
  done
  echo
else
  echo "Skipping automatic module probe."
  echo
fi

# end main loop
break
done
