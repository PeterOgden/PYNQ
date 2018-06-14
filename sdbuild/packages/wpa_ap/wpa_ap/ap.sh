#!/bin/bash

ifconfig wlan0 up
. /etc/environment
cd /usr/local/share/wpa_ap
wlan0_found=false

for index in {1..10}:
do
	wlan0_status=$(wpa_cli -i wlan0 ping)
	if [ $wlan0_status == "PONG" ]; then
		wlan0_found=true
		break
	fi
	sleep 1
done

if [ $wlan0_found == "true" ]; then
	for index in {1..10}:
	do
		for index in {1..10}:
		do
			scan=$(wpa_cli -i wlan0 scan)
			if [[ $scan == "OK" ]]; then
				break
			else
				sleep 1
			fi
		done
	done
fi

# Create a new managed mode interface wlan1 to run AP
iw phy phy0 interface add wlan1 type managed

hid=$(ifconfig -a | grep wlan1 | sed "s,wlan1.*HWaddr \(.*\),\1," | tr -d ": ")
ip=192.168.2.1

sed "s,pynq,pynq_$hid," wpa_ap.conf > wpa_ap_actual.conf

ifconfig wlan1 down
sleep 2
wpa_supplicant -c ./wpa_ap_actual.conf  -iwlan1 &

ifconfig wlan1 $ip

