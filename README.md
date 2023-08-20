# usbserialcaretaker

A daemon bash script to start and stop getty processes for USB serial dongles on a Raspberry Pi.

# Quick start

Take a a backup of the file `/usr/lib/systemd/system/serial-getty@.service`:

```
sudo cp -p /usr/lib/systemd/system/serial-getty@.service /usr/lib/systemd/system/serial-getty@.service.install
```

Edit the file `/usr/lib/systemd/system/serial-getty@.service` and locate the line which reads:

```
ExecStart=-/sbin/agetty -o '-p -- \\u' --keep-baud 115200,57600,38400,9600 %I $TERM
```

Change this line to read:

```
ExecStart=-/sbin/agetty 115200 %I $TERM
```

Save the change to the file `/usr/lib/systemd/system/serial-getty@.service`.

Run the command:

```
sudo make rootinstall
```

Output should be similar to:

```
sudo cp usbserialcaretaker.sh /usr/local/bin/usbserialcaretaker
sudo chown root:root          /usr/local/bin/usbserialcaretaker
sudo chmod u=rwx,go=r         /usr/local/bin/usbserialcaretaker
sudo cp usbserialcaretaker.service /etc/systemd/system/usbserialcaretaker.service
sudo chown root:root               /etc/systemd/system/usbserialcaretaker.service
sudo chmod u=rx,go=r               /etc/systemd/system/usbserialcaretaker.service
sudo systemctl daemon-reload
sudo systemctl enable usbserialcaretaker.service
sudo systemctl start usbserialcaretaker.service
```

Check the daemon is running:

```
sudo systemctl status usbserialcaretaker.service
```

Output should be similar to:

```
+ usbserialcaretaker.service - USB serial device caretaker daemon
     Loaded: loaded (/etc/systemd/system/usbserialcaretaker.service; enabled; vendor preset: enabled)
     Active: active (running) since Sun 2023-08-20 16:56:44 BST; 15min ago
       Docs: https://github.com/andycranston/usbserialcaretaker
   Main PID: 435 (usbserialcareta)
      Tasks: 2 (limit: 1595)
        CPU: 3.456s
     CGroup: /system.slice/usbserialcaretaker.service
             ├─ 435 /bin/bash /usr/local/bin/usbserialcaretaker
             └─2579 sleep 5

Aug 20 16:56:44 raspberrypi systemd[1]: Started USB serial device caretaker daemon.
```

Connect a USB serial dongle to one of the USB ports on the Raspberry Pi. Connect a serial port terminal emulator
running at 115200 baud to the port on the USB serial dongle. You might need to use a null-modem cable.

Verify that a login prompt to the Raspberry Pi is displayed and that you can login.


# How it works

The `usbserialcaretaker` script runs in a continous loop. On each run of the loop
is looks for device file names:

```
/dev/ttyUSB0
```

through to:

```
/dev/ttyUSB9
```

It then compares the names found on the last run of the loop with the current run. If a new device has appeared then
the command:

```
systemctl start serial-getty@ttyUSBX.service
```

where `ttyUSBX` is changed to the name of the device found (e.g. `ttyUSB0`).

Similarly for any devices which were present in the last run but are no longer present a command
similar to:

```
systemctl stop serial-getty@ttyUSBX.service
```

is run.

So when a USB serial dongle is inserted a device file such as `ttyUSB0` is created and this will cause the
`usbserialcaretaker` script to start a serial getty on that dongle which in turn displays a login prompt.

# Limitations

If more than ten `ttyUSBX` files get created the `usbserialcaretaker` script will get confused.

After a reboot any USN serial dongles may have to temporarily disconnected for ten seconds or so and then reconnected
to get a login prompt displayed.

Sometimes the file:

```
/usr/lib/systemd/system/serial-getty@.service
```

gets reset back to its default content and the edit to the line which starts:

```
ExecStart=...
```

will need to be made again.


----------------
End of README.md
