#!/bin/bash

echo 'INTERFACES="usb0 wlan1"' > /etc/default/isc-dhcp-server

cat - >> /etc/dhcp/dhcpd.conf <<EOT

subnet 192.168.2.0 netmask 255.255.255.0 {
   option subnet-mask 255.255.255.0;
   option broadcast-address 192.168.2.0;
   range 192.168.2.2 192.168.2.100;
}
EOT

cat - > /etc/network/interfaces.d/wlan0 <<EOT
iface wlan0 inet dhcp
	wireless_mode managed
	wireless_essid any
	wpa-driver wext
	wpa-conf /etc/wpa_supplicant.conf
EOT

systemctl enable wpa_ap.service
