#!/bin/bash
#
# @(!--#) @(#) setup.sh, sversion 0.1.0, fversion 001, 20-august-2023
#
# set up the usbserialcaretaker script and service
#

set -u

SERIAL_GETTY=/usr/lib/systemd/system/serial-getty@.service
SCRIPT_FILENAME=usbserialcaretaker.sh
SERVICE_FILENAME=usbserialcaretaker.sh

progname=`basename $0`

echo "must run as root"

if [ ! -r "$SERIAL_GETTY" ]
then
  echo "$progname: the serial getty file \"$SERIAL_GETTY\" does not exist!" 1>&2
  exit 1
fi

backupfile="$SERIAL_GETTY".`date '+%s'`
sudo cp -p "$SERIAL_GETTY" $backupfile
if [ $? -ne 0 ]
then
  echo "$progname: error trying to create a backup of the serial getty file \"$SERIAL_GETTY\"" 1>&2
  exit 1
fi

execcount=`grep '^ExecStart=' "$SERIAL_GETTY" | wc -l | awk '{ print $1 }'`
if [ $execcount -eq 0 ]
then
  echo "$progname: the serial getty file \"$SERIAL_GETTY\" does not have a ExecStart= line" 1>&2
  exit 1
fi
if [ $execcount -gt 1 ]
then
  echo "$progname: the serial getty file \"$SERIAL_GETTY\" has more than one ExecStart= lines" 1>&2
  exit 1
fi

sed -e 's|^ExecStart=.*|ExecStart=-/sbin/agetty 115200 %I $TERM|g' $backupfile > $SERIAL_GETTY



cp usbserialcaretaker.sh /usr/local/bin/usbserialcaretaker
chown root:root          /usr/local/bin/usbserialcaretaker
chmod u=rwx,go=r         /usr/local/bin/usbserialcaretaker

cp usbserialcaretaker.service /etc/systemd/system/usbserialcaretaker.service
chown root:root               /etc/systemd/system/usbserialcaretaker.service
chmod u=rx,go=r               /etc/systemd/system/usbserialcaretaker.service

systemctl daemon-reload
systemctl enable usbserialcaretaker.service
systemctl start usbserialcaretaker.service


