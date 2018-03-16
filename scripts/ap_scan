#!/bin/sh
#
# start_network 3rd generation script.
#
# Synopsis:
#    start_network [interface]
# or, if you're calling it as wpa_cli does:
#    start_network [interface] [DIS]CONNECT
# or, when symlinked as ap_scan:
#    ap_scan [interface]
#
# This is the third-generation start_network script.  It differs from the
# previous generations in that it uses wpa_supplicant to do most of the
# heavy lifting, rather than iwconfig / iwpriv, when connecting to wireless
# networks.
#
# When running as ap_scan, if the file /tmp/hidden_ssid exists, then ap_scan
# will disassociate with the current network, attempt to associate with
# the specified network, rescan, disassociate, then reassociate with the
# previous network.


echo >/tmp/network.connected

if test ! -d /tmp/chumby; then
        mkdir -p /tmp/chumby
fi

if [ -e /tmp/flashplayer_started ]; then
        rm /tmp/flashplayer_started
fi

echo "<network>" >/tmp/chumby/network_status.xml
echo "<interface if=\"wlan0\" up=\"true\" link=\"true\" ip=\"127.0.0.1\" broadcast=\"127.0.0.255\" netmask=\"255.255.255.0\" gateway=\"127.0.0.1\" nameserver1=\"127.0.0.1\">" >>/tmp/chumby/network_status.xml
echo "<stats rx_bytes=\"1337\" rx_packets=\"1337\" rx_errs=\"0\" rx_drop=\"0\" rx_fifo=\"0\" rx_frame=\"0\" rx_compressed=\"0\" rx_multicast=\"0\" tx_bytes=\"1337\" tx_packets=\"1337\" tx_errs=\"0\" tx_drop=\"0\" tx_fifo=\"0\" tx_colls=\"0\" tx_carrier=\"0\" tx_compressed=\"0\" wifi_link=\"60.\" wifi_level=\"-50.\" wifi_noise=\"-256\" />" >>/tmp/chumby/network_status.xml
echo "</interface>" >>/tmp/chumby/network_status.xml
echo "<configuration gateway=\"\" ip=\"\" nameserver1=\"\" encryption=\"NONE\" key=\"\" hwaddr=\"00:DE:AD:BE:EF:00\" nameserver2=\"\" auth=\"OPEN\" netmask=\"\" type=\"wlan\" ssid=\"xxxxx\" allocation=\"dhcp\" encoding=\"\" />" >>/tmp/chumby/network_status.xml
echo "</network>" >>/tmp/chumby/network_status.xml

