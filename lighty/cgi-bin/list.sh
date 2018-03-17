#!/bin/sh

echo "HTTP/1.1 200 ok"
echo "Content-type:  text/xml"
echo ""
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
xdt=`date -u | sed -e s/UTC/+0000/g`
if [ -f /psp/c1 ]; then
count=`ls ../html/zchannel/channels.c1 |wc -w`
echo "<profiles count=\"$count\">"
file_list=`ls ../html/zchannel/channels.c1`
 for f in $file_list
 do 
wcount=`ls ../html/zchannel/channels.c1/$f |wc -w`
echo "<profile id=\"$f\">"
echo "  <name>$f</name>"
echo "  <description>$f</description>"
echo "  <user id=\"1\">Zurk</user>"
echo "  <info type=\"Profile\" updated=\"$xdt\" master=\"false\" pending=\"0\" unaccepted=\"0\" origin=\"\" created=\"$xdt\" published=\"\"/>"
echo "  <widget_instances count=\"$wcount\" thumbnail=\"file:////mnt/usb/www/generic.jpg\"/>"
echo "</profile>"
 done
else
count=`ls ../html/zchannel/channels.c8 |wc -w`
echo "<profiles count=\"$count\">"
file_list=`ls ../html/zchannel/channels.c8`
 for f in $file_list
 do 
wcount=`ls ../html/zchannel/channels.c8/$f |wc -w`
echo "<profile id=\"$f\">"
echo "  <name>$f</name>"
echo "  <description>$f</description>"
echo "  <user id=\"1\">Zurk</user>"
echo "  <info type=\"Profile\" updated=\"$xdt\" master=\"false\" pending=\"0\" unaccepted=\"0\" origin=\"\" created=\"$xdt\" published=\"\"/>"
echo "  <widget_instances count=\"$wcount\" thumbnail=\"file:////mnt/usb/www/generic.jpg\"/>"
echo "</profile>"
 done
fi
echo "</profiles>"
