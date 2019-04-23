#!/bin/sh
EXTIF=$(route -n | grep ^0.0.0.0 | awk '{print $8}')
INTIF=$(ifconfig -a | egrep 'encap:(Ethernet|Point)' | awk '{print $1}' | grep -v ${EXTIF} | head -n 1)



# Ensure we have an internal and an external interface.
if [ "x${INTIF}" = "x" -o "x${INTIF}" = "x" ]
then
    echo "Only one interface detected.  Not starting router."
    exit
fi


ifconfig ${INTIF} down

# Write the hostapd config file.
cat > /tmp/hostapd.conf <<EOF
interface=${INTIF}
driver=nl80211
logger_syslog=-1
logger_syslog_level=2
logger_stdout=-0
logger_stdout_level=2
dump_file=/tmp/hostapd.dump
ctrl_interface=/var/run/hostapd
ctrl_interface_group=0
ssid=ChumbyFW
country_code=US
hw_mode=g
channel=11
beacon_int=100
#dtim_period=2
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
eapol_key_index_workaround=0
eap_server=0
own_ip_addr=127.0.0.1
EOF



# Run hostapd, to set up the access point, ifthe internal interface is a
# wireless card.
echo ${INTIF} | grep -q ^wlan && hostapd /tmp/hostapd.conf -B


# Bring up the internal wifi interface.
ifconfig ${INTIF} 10.0.50.1

# Run dnsmasq, which is a combination DNS relay and DHCP server.
mkdir -p /var/lib/misc
dnsmasq -i ${INTIF} -F 10.0.50.100,10.0.50.250,15000 -K


# Set up IP forwarding
iptables -t nat -F
iptables -t nat -A POSTROUTING -o ${EXTIF} -j MASQUERADE
echo 1 > /proc/sys/net/ipv4/ip_forward

