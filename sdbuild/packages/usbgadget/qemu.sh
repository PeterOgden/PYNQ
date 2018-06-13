#!/bin/bash

echo 'INTERFACES="usb0"' > /etc/default/isc-dhcp-server
cat - > /etc/dhcp/dhcpd.conf <<EOT
ddns-update-style none;

default-lease-time 600;
max-lease-time 7200;

subnet 192.168.3.0 netmask 255.255.255.0 {
   option subnet-mask 255.255.255.0;
   option broadcast-address 192.168.3.0;
   range 192.168.3.100 192.168.3.150;
}
EOT

systemctl enable usbgadget
systemctl enable serial-getty@ttyGS0
