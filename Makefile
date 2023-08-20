rootinstall:
	sudo cp usbserialcaretaker.sh /usr/local/bin/usbserialcaretaker
	sudo chown root:root          /usr/local/bin/usbserialcaretaker
	sudo chmod u=rwx,go=r         /usr/local/bin/usbserialcaretaker
	sudo cp usbserialcaretaker.service /etc/systemd/system/usbserialcaretaker.service
	sudo chown root:root               /etc/systemd/system/usbserialcaretaker.service
	sudo chmod u=rx,go=r               /etc/systemd/system/usbserialcaretaker.service
	sudo systemctl daemon-reload
	sudo systemctl enable usbserialcaretaker.service
	sudo systemctl start usbserialcaretaker.service
