#!/bin/sh
#
# network_status.sh - polls the status of the network interface and outputs XML to /tmp/chumby/network_status.xml
#
# Ken Steele
# Copyright (c) Chumby Industries, 2007-2008
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
#
# Change History
# 081806 - Steve Adler
#  - adapt to Bourne shell syntax to get running on BusyBox


SCRIPT_ROOT=${CHUMBY_SCRIPTS:-/usr/chumby/scripts}
NETWORK_INTERFACE=`$SCRIPT_ROOT/network_interface`

IFCONFIG=`ifconfig $NETWORK_INTERFACE 2>&1`
XML=/tmp/chumby/network_status.xml
WATCHDOG_RUNNING=0

ERR_BASE="ERRORS_"
EC=0

if test ! -d /tmp/chumby; then
	mkdir -p /tmp/chumby
fi

if [ -e /tmp/flashplayer_started ]; then
	WATCHDOG_RUNNING=1
	rm /tmp/flashplayer_started
fi

if [ ! -e /psp/network_config ]; then
    ERROR=`echo "$ERR_BASE$EC"`
    eval "$ERROR=\"no network configuration\""
    EC=`expr $EC + 1`
fi

if echo "$IFCONFIG" | grep -q "Device not found"; then
    ERROR=`echo "$ERR_BASE$EC"`
    eval "$ERROR=\"$NETWORK_INTERFACE device not found\""
    EC=`expr $EC + 1`
fi

echo '<network>' >$XML
echo -n -e '\t<interface ' >>$XML

echo -n "if=\"$NETWORK_INTERFACE\" " >>$XML

echo -n 'up=' >>$XML
if echo "$IFCONFIG" | grep -q "UP"; then
	echo -n '"true" ' >>$XML
else
    echo -n '"false" ' >>$XML
    ERROR=`echo "$ERR_BASE$EC"`
    eval "$ERROR=\"$NETWORK_INTERFACE interface is down\""
    EC=`expr $EC + 1`
fi

echo -n 'link=' >>$XML
if echo "$IFCONFIG" | grep -q "RUNNING"; then
	echo -n '"true" ' >>$XML
else
    echo -n '"false" ' >>$XML
    ERROR=`echo "$ERR_BASE$EC"`
    eval "$ERROR=\"$NETWORK_INTERFACE link is down\""
    EC=`expr $EC + 1`
fi

IP=`echo "$IFCONFIG" |grep "inet addr"|awk -F ":" '{print $2}'|awk '{print $1}'`;
if [ ! "$IP" ]; then
    ERROR=`echo "$ERR_BASE$EC"`
    eval "$ERROR=\"failed to obtain IP address\""
    EC=`expr $EC + 1`
fi

if echo "$IFCONFIG" | grep -q 'inet addr'; then
	echo -n "$IFCONFIG" | egrep 'inet addr' | sed 's/ P-t-P:/ Bcast:/g' | awk '{ORS="";OFS="\" ";print $2, $3, $4"\" "}' |sed -e 's/addr:/ip="/' -e 's/Bcast:/broadcast="/' -e 's/Mask:/netmask="/' >>$XML
fi

# parse gateway                                                                                                                                                                                                                            
GW=`route -n|grep "^0\.0\.0\.0"|grep $NETWORK_INTERFACE| awk '{print $2}'`;
echo -n "gateway=\"$GW\"" >>$XML

# check nameservers
if [ -e /etc/resolv.conf ]; then
    ns=0
    for i in `cat /etc/resolv.conf| egrep "^nameserver"| awk '{print $2}'`; do
        ns=`expr $ns + 1`
        echo -n " nameserver$ns=\"$i\"" >>$XML
    done
fi
echo ">" >>$XML

#
# stats node
#

STATS=`cat /proc/net/dev |grep $NETWORK_INTERFACE | sed -e 's/.*://'`
echo -n -e "\\t\\t<stats " >>$XML
echo -n "$STATS" | awk '{ORS="";print "rx_bytes=\""$1"\"", "rx_packets=\""$2"\"", "rx_errs=\""$3"\"", "rx_drop=\""$4"\"", "rx_fifo=\""$5"\"", "rx_frame=\""$6"\"", "rx_compressed=\""$7"\"", "rx_multicast=\""$8"\"", "tx_bytes=\""$9"\"", "tx_packets=\""$10"\"", "tx_errs=\""$11"\"", "tx_drop=\""$12"\"", "tx_fifo=\""$13"\"", "tx_colls=\""$14"\"", "tx_carrier=\""$15"\"", "tx_compressed=\""$16"\" "}' >>$XML
echo -n `cat /proc/net/wireless|grep $NETWORK_INTERFACE|awk '{ORS="";print "wifi_link=\""$3"\"", "wifi_level=\""$4"\"", "wifi_noise=\""$5"\""}'` >>$XML
echo " />" >>$XML

if [ "$1" != "--fast" ]; then
    wget --timeout=20 -t 3 -O /dev/null "http://www.chumby.com/crossdomain.xml"
    if [ $? != 0 ]; then
        ERROR=`echo "$ERR_BASE$EC"`
        eval "$ERROR=\"chumby.com is unreachable\""
        EC=`expr $EC + 1`
    fi
fi

i=0
while [ $i -lt $EC ]; do
	eval "ERRSTR=\$`echo $ERR_BASE$i`"
	echo -e "\\t\\t<error>$ERRSTR</error>" >>$XML
	i=`expr $i + 1`
done;

echo -e "\\t</interface>" >>$XML

#
# configuration node
#

if [ -e /psp/network_config ]; then
    network_config=`cat /psp/network_config`
    echo "$network_config" >>$XML
fi

echo "</network>" >>$XML

echo "<network>" >$XML
echo "<interface if=\"wlan0\" up=\"true\" link=\"true\" ip=\"127.0.0.1\" broadcast=\"127.0.0.255\" netmask=\"255.255.255.0\" gateway=\"127.0.0.1\" nameserver1=\"127.0.0.1\">" >>$XML
echo "<stats rx_bytes=\"1337\" rx_packets=\"1337\" rx_errs=\"0\" rx_drop=\"0\" rx_fifo=\"0\" rx_frame=\"0\" rx_compressed=\"0\" rx_multicast=\"0\" tx_bytes=\"1337\" tx_packets=\"1337\" tx_errs=\"0\" tx_drop=\"0\" tx_fifo=\"0\" tx_colls=\"0\" tx_carrier=\"0\" tx_compressed=\"0\" wifi_link=\"60.\" wifi_level=\"-50.\" wifi_noise=\"-256\" />" >>$XML
echo "</interface>" >>$XML
echo "<configuration gateway=\"\" ip=\"\" nameserver1=\"\" encryption=\"NONE\" key=\"\" hwaddr=\"00:DE:AD:BE:EF:00\" nameserver2=\"\" auth=\"OPEN\" netmask=\"\" type=\"wlan\" ssid=\"xxxxx\" allocation=\"dhcp\" encoding=\"\" />" >>$XML
echo "</network>" >>$XML

cat $XML

if [ "$WATCHDOG_RUNNING" = 1 ]; then
	echo 1 >/tmp/flashplayer_started
fi

[ ${EC} = 0 ] && exit 0
exit 0

