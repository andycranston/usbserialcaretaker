#!/bin/bash
#
# @(!--#) @(#) usbserialcaretaker.sh, sversion 0.1.0, fversion 001, 20-august-2023
#


set -u

progname=`basename $0`

DEVDIR=/dev
SLEEPDELAY=5
DIFFERENCEDELAY=2

cd $DEVDIR 2>/dev/null
retcode=$?

if [ $retcode -ne 0 ]
then
  logger -t $progname "Unable to change to device directory $DEVDIR - exiting"
  exit 1
fi

lastttys=`ls ttyUSB[0-9] 2>/dev/null`

while true
do
  sleep $SLEEPDELAY

  ttys=`ls ttyUSB[0-9] 2>/dev/null`

  ### echo "[$lastttys] [$ttys]"

  if [ "$lastttys" != "$ttys" ]
  then
    logger -t $progname "USB serial device(s) added or removed"

    sleep $DIFFERENCEDELAY

    for tty in $ttys
    do
      ### echo "Seeing if $tty in last ttys"

      echo $lastttys | grep $tty >/dev/null
      retcode=$?

      if [ $retcode -eq 1 ]
      then
        logger -t $progname "starting tty service on $tty"
        sudo systemctl start serial-getty@${tty}.service
      fi
    done

    for tty in $lastttys
    do
      ### echo "Seeing if $tty in ttys"

      echo $ttys | grep $tty >/dev/null
      retcode=$?

      if [ $retcode -eq 1 ]
      then
        logger -t $progname "stopping tty service on $tty"
        sudo systemctl stop serial-getty@${tty}.service
      fi
    done
  fi

  lastttys="$ttys"
done


