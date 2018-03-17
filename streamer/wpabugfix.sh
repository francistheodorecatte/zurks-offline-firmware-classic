#!/bin/sh

while [ 1 ]
do
	RSSI=`iwconfig wlan0 | grep Signal | awk '{print $4}' | cut -d ":" -f 2 | sed -e 's/level=//g'`
	if [  ${RSSI} -lt "-60" ]
	then
		/usr/local/sbin/wpa_cli ap_scan 1 >/dev/null
		/usr/local/sbin/wpa_cli scan >/dev/null
		/usr/local/sbin/wpa_cli reconnect >/dev/null
#		iwlist wlan0 scan >/dev/null
#		sleep 2
		sleep 200
	else
#		sleep 5
		sleep 500
	fi
done

