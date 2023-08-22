#!/bin/bash
#
# @(!--#) @(#) setup.sh, sversion 0.1.0, fversion 003, 22-august-2023
#
# set up the usbserialcaretaker script and service
#

set -u

SERIAL_GETTY=/usr/lib/systemd/system/serial-getty@.service

#
# Main
#

PATH=/bin:/usr/bin:/sbin:/usr/sbin
export PATH

progname=`basename $0`

echo "Script $progname started"

user=`id | cut -d'(' -f2 | cut -d')' -f1`

if [ "$user" != "root" ]
then
  echo "$progname: must with with root priviledge - e.g: sudo ./$progname" 1>&2
  exit 1
fi

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
if [ $? -ne 0 ]
then
  echo "$progname: error trying to edit the getty file \"$SERIAL_GETTY\"" 1>&2
  exit 1
fi

echo "Stopping USB serial caretaker service (errors can be ignored)"
sudo systemctl stop usbserialcaretaker.service

echo "Installing USB serial caretaker script in /usr/local/bin"
cp usbserialcaretaker.sh /usr/local/bin/usbserialcaretaker
chown root:root          /usr/local/bin/usbserialcaretaker
chmod u=rwx,go=r         /usr/local/bin/usbserialcaretaker

echo "Installing USB serial caretaker service in /etc/systemd/system"
cp usbserialcaretaker.service /etc/systemd/system/usbserialcaretaker.service
chown root:root               /etc/systemd/system/usbserialcaretaker.service
chmod u=rx,go=r               /etc/systemd/system/usbserialcaretaker.service

echo "Reloading systemd daemon definitions"
systemctl daemon-reload

echo "Enabling USB serial caretaker service"
systemctl enable usbserialcaretaker.service

echo "(Re-)starting USB serial caretaker service"
systemctl start usbserialcaretaker.service

echo "Script $progname completed"

exit 0
