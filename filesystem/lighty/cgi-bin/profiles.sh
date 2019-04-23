#!/bin/sh
ID=`echo "$QUERY_STRING" | awk -F= '{print $2}' | awk -F'&' '{print $1}' | sed -e 's/%2C//g' |  sed -e 's/%20//g'`
echo "HTTP/1.1 200 ok"
echo "Content-type:  text/xml"
echo ""
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
xdt=`date -u | sed -e s/UTC/+0000/g`
if [ -f /psp/c1 ]; then
count=`ls ../html/zchannel/channels.c1/$ID |wc -w`
xpf=`ls ../html/zchannel/channels.c1`
echo "<profile id=\"$ID\">"
echo "  <name>$ID</name>"
echo "  <description>$ID</description>"
echo "  <user username=\"Zurk\">"
echo "<profiles>"
for x in $xpf
do 
echo "     <profile  unaccepted=\"0\" name=\"$x\" id=\"$x\" />"
done
echo "</profiles>"
echo "</user>"
echo "<skin href=\"/xml/skins/00000000-0000-0000-0000-000000000001\" name=\"Standard\" id=\"00000000-0000-0000-0000-000000000001\"/>"
echo " <access access=\"private\" id=\"0\"/>"
echo "  <widget_instances>"
file_list=`ls ../html/zchannel/channels.c1/$ID`
 for f in $file_list
 do 
echo "<widget_instance id=\"$f\">"
echo "  <name>$f</name>"
echo "<widget id=\"$f\">"
echo "  <name>$f</name>"
echo "  <description>$f</description>"
echo "  <version>1.0</version>"
tim=`echo 180`
  if [ -f ../html/zchannel/channels.c1/$ID/$f/timeout ]; then
tim=`cat ../html/zchannel/channels.c1/$ID/$f/timeout`
  fi
echo "  <mode mode=\"timeout\" time=\"$tim\"/>"
echo "  <access sendable=\"false\" deletable=\"false\" access=\"private\" virtualable=\"false\"/>"
echo "  <user username=\"Zurk\"/>"
echo "  <thumbnail href=\"http://localhost/zchannel/channels.c1/$ID/$f/thumbnail.jpg\" contenttype=\"image/jpeg\"/>"
echo "  <template href=\"http://localhost/zchannel/channels.c1/$ID/$f/movie.swf\" contenttype=\"application/x-shockwave-flash\"/>"
echo "  <movie href=\"http://localhost/zchannel/channels.c1/$ID/$f/movie.swf\" contenttype=\"application/x-shockwave-flash\"/>"
echo "  <rating count=\"63\" value=\"4.8889\"/>"
echo "</widget>"
echo "  <widget_parameters>"
cat ../html/zchannel/channels.c1/$ID/$f/parameters.txt
echo "  </widget_parameters>"
echo "<rating rating=\"5\"/>"
echo "</widget_instance>"
 done
else
count=`ls ../html/zchannel/channels.c8/$ID |wc -w`
xpf=`ls ../html/zchannel/channels.c8`
echo "<profile id=\"$ID\">"
echo "  <name>$ID</name>"
echo "  <description>$ID</description>"
echo "  <user username=\"Zurk\">"
echo "<profiles>"
for x in $xpf
do 
echo "     <profile  unaccepted=\"0\" name=\"$x\" id=\"$x\" />"
done
echo "</profiles>"
echo "</user>"
echo "<skin href=\"/xml/skins/00000000-0000-0000-0000-000000000001\" name=\"Standard\" id=\"00000000-0000-0000-0000-000000000001\"/>"
echo " <access access=\"private\" id=\"0\"/>"
echo "  <widget_instances>"
file_list=`ls ../html/zchannel/channels.c8/$ID`
 for f in $file_list
 do 
echo "<widget_instance id=\"$f\">"
echo "  <name>$f</name>"
echo "<widget id=\"$f\">"
echo "  <name>$f</name>"
echo "  <description>$f</description>"
echo "  <version>1.0</version>"
tim=`echo 180`
  if [ -f ../html/zchannel/channels.c8/$ID/$f/timeout ]; then
tim=`cat ../html/zchannel/channels.c8/$ID/$f/timeout`
  fi
echo "  <mode mode=\"timeout\" time=\"$tim\"/>"
echo "  <access sendable=\"false\" deletable=\"false\" access=\"private\" virtualable=\"false\"/>"
echo "  <user username=\"Zurk\"/>"
echo "  <thumbnail href=\"http://localhost/zchannel/channels.c8/$ID/$f/thumbnail.jpg\" contenttype=\"image/jpeg\"/>"
echo "  <template href=\"http://localhost/zchannel/channels.c8/$ID/$f/movie.swf\" contenttype=\"application/x-shockwave-flash\"/>"
echo "  <movie href=\"http://localhost/zchannel/channels.c8/$ID/$f/movie.swf\" contenttype=\"application/x-shockwave-flash\"/>"
echo "  <rating count=\"63\" value=\"4.8889\"/>"
echo "</widget>"
echo "  <widget_parameters>"
cat ../html/zchannel/channels.c8/$ID/$f/parameters.txt
echo "  </widget_parameters>"
echo "<rating rating=\"5\"/>"
echo "</widget_instance>"
 done
fi
echo "  </widget_instances>"
echo "</profile>"

