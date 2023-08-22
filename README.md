# usbserialcaretaker

A bash script to start and stop getty processes for USB serial dongles on a Raspberry Pi.
Runs in the background via a systemd service.

# Quick start

Run the following command:

```
sudo ./setup.sh
```

Plug a USB serial dongle into a free USB port on the Raspberry Pi.

Attach a serial terminal emulator to the DB9 connector of the dongle.

Configure to run at 115200 baud, 8 bits with no parity.

A login prompt should be displayed.

# Why is this useful?

If a Raspberry Pi is being run "headless" with the only connections being
power and networking then if the network connection fails it will not be
possible to login and investigate.

By being able to attach a USB serial dongle and get a login prompt
an operator will be able to diagnose the network connectivity issue.
Once the network connection is restored just unplug the USB serial dongle.

# Detail of what the `setup.sh` script does

This `setup.sh` script does the following:

The file `/usr/lib/systemd/system/serial-getty@.service` is modified. Specifically the line:

```
ExecStart=-/sbin/agetty -o '-p -- \\u' --keep-baud 115200,57600,38400,9600 %I $TERM
```

is changed to:

```
ExecStart=-/sbin/agetty 115200 %I $TERM
```

If the usbserialcaretaker service has been previously installed then the service is stopped.

The bash script `usbserialcaretaker.sh` is copied to the `/usr/local/bin` directory.

The service file `usbserialcaretaker.service` is copied to the `/etc/systemd/system` directory.

The systemd daemon service files are reloaded.

The usbserialcaretaker service is enabled.

The usbserialcaretaker service is started.

# How the `usbserialcaretaker` bash script works

The `usbserialcaretaker` script runs in a continous loop.

On each run of the loop it looks for device file names:

```
/dev/ttyUSB0
```

through to:

```
/dev/ttyUSB9
```

It then compares the names found on the last run of the loop with the current run. If a new device has appeared then
the following command is run:

```
systemctl start serial-getty@ttyUSBX.service
```

where `ttyUSBX` is changed to the name of the device found (e.g. `ttyUSB0`).

Similarly for any devices which were present in the last run but are no longer present 
in the curent run a command similar to:

```
systemctl stop serial-getty@ttyUSBX.service
```

is run.

So when a USB serial dongle is inserted a device file such as `ttyUSB0` is created and this will cause the
`usbserialcaretaker` script to start a serial getty on that dongle which in turn displays a login prompt.

# Limitations

If more than ten `ttyUSBX` files get created the `usbserialcaretaker` script will very likely get confused.

After a reboot any USB serial dongles may have to be temporarily disconnected for ten seconds or so and then reconnected
to get a login prompt displayed.

----------------
End of README.md
