#!/bin/sh      

ID=`echo "$QUERY_STRING" | awk -F= '{print $2}' | awk -F'&' '{print $1}' | sed -e 's/%2C//g' |  sed -e 's/%20//g'`
echo "Content-type: text/html"                                                  
echo ""
echo "<html><head>"
echo "<title>Chumby Multi-Channel Widget Editor</title>"
echo "</head>"
echo "<body>"
echo "<h4>Zurk's Multi Channel Widget Editor</h4><form name=\"spark\">"
echo "Setting default Chumby Channel : $ID<br>"
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" >/mnt/usb/lighty/html/xapis/device/index
echo "<chumby updated=\"Sun Aug 04 21:44:29 +0000 2014\" anonymous=\"false\" id=\"1\" authorized=\"Sun Aug 04 21:44:29 +0000 2014\" created=\"Sat Jul 24 19:16:22 +0000 2014\">" >> /mnt/usb/lighty/html/xapis/device/index
echo " <name>ZChumby</name> " >> /mnt/usb/lighty/html/xapis/device/index
echo "  <user id=\"1\">Zurk</user>" >> /mnt/usb/lighty/html/xapis/device/index
echo "  <profile id=\"$ID\">$ID</profile>" >> /mnt/usb/lighty/html/xapis/device/index
echo "  <dcid version=\"0002\" hash=\"0003-1001-0001-0001\"/>" >> /mnt/usb/lighty/html/xapis/device/index
echo "  <control_panel enable=\"true\" name=\"Control Panel\"/>" >> /mnt/usb/lighty/html/xapis/device/index
echo "</chumby>" >> /mnt/usb/lighty/html/xapis/device/index
echo "...Completed. <br><br>"
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > /mnt/usb/lighty/html/chumbies/index.html
echo "<chumby id=\"999999\">" >> /mnt/usb/lighty/html/chumbies/index.html
echo "  <name>ZChumby</name>" >> /mnt/usb/lighty/html/chumbies/index.html
echo "  <profile href=\"/xml/profiles\" name=\"$ID\" id=\"99999\"/> " >> /mnt/usb/lighty/html/chumbies/index.html
echo "  <user username=\"offline-user\"/> " >>/mnt/usb/lighty/html/chumbies/index.html
echo " </chumby> " >> /mnt/usb/lighty/html/chumbies/index.html
sync
echo "..Please power off your chumby and start it to load the default channel..<br><br></form></body></html>"
