#!/bin/sh
ID=`echo "$REQUEST_URI" | sed -e 's/?[^?]*$//g' | sed -re 's/^.+\///'`
echo "HTTP/1.1 200 ok"
echo "Content-type:  text/xml"
echo ""
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
xdt=`date -u | sed -e s/UTC/+0000/g`
if [ -f /psp/c1 ]; then
count=`ls ../html/zchannel/channels.c1/$ID |wc -w`
echo "<profile id=\"$ID\">"
echo "  <name>$ID</name>"
echo "  <description>$ID</description>"
echo "  <user id=\"1\">Zurk</user>"
echo "  <info type=\"Profile\" updated=\"$xdt\" master=\"false\" pending=\"0\" unaccepted=\"0\" origin=\"\" created=\"$xdt\" published=\"\"/>"
echo "  <widget_instances count=\"$count\" thumbnail=\"file:////mnt/usb/www/generic.jpg\">"
file_list=`ls ../html/zchannel/channels.c1/$ID`
 for f in $file_list
 do
echo "<widget_instance id=\"$f\">"
echo "  <name>$f</name>"
echo "  <info updated=\"$xdt\" access=\"private\" secure=\"\" origin=\"manual\" created=\"$xdt\"/>"
tim=`echo 180`
  if [ -f ../html/zchannel/channels.c1/$ID/$f/timeout ]; then
tim=`cat ../html/zchannel/channels.c1/$ID/$f/timeout`
  fi
echo "  <play mode=\"timeout\" time=\"$tim\"/>"
echo "  <rating value=\"0\"/>"
echo "<widget id=\"$f\">"
echo "  <name>$f</name>"
echo "  <description>$f</description>"
echo "  <version>1.0</version>"
echo "  <play mode=\"timeout\" time=\"$tim\"/>"
echo "  <user type=\"community\" id=\"1001001001\" username=\"Zurk\"/>"
echo "  <security sendable=\"false\" previewable=\"false\" access=\"private\" virtualable=\"false\" approval=\"approved\" deletable=\"false\" overlay=\"true\"/>"
echo "  <rating count=\"63\" value=\"4.8889\"/>"
echo "  <thumbnail href=\"http://localhost/zchannel/channels.c1/$ID/$f/thumbnail.jpg\"/>"
echo "  <movie href=\"http://localhost/zchannel/channels.c1/$ID/$f/movie.swf\" contenttype=\"application/x-shockwave-flash\"/>"
echo "  <swfs>"
echo "    <swf width=\"800\" microphone=\"false\" kb=\"false\" camera=\"false\" as_version=\"2\" accelerometer=\"false\" previewable=\"true\" content-type=\"application/x-shockwave-flash\" href=\"http://localhost/zchannel/channels.c1/$ID/$f/movie.swf\" fixed_ar=\"true\" swf_version=\"7\" height=\"600\" bgcolor=\"000000\" supports_browser=\"false\" pointing=\"false\" resolution=\"\" scalable=\"true\" requires_sound=\"true\"/>"
echo "  </swfs>"
echo "</widget>"
echo "  <parameters>"
cat ../html/zchannel/channels.c1/$ID/$f/parameters.txt
echo "  </parameters>"
echo "</widget_instance>"
 done
else
count=`ls ../html/zchannel/channels.c8/$ID |wc -w`
echo "<profile id=\"$ID\">"
echo "  <name>$ID</name>"
echo "  <description>$ID</description>"
echo "  <user id=\"1\">Zurk</user>"
echo "  <info type=\"Profile\" updated=\"$xdt\" master=\"false\" pending=\"0\" unaccepted=\"0\" origin=\"\" created=\"$xdt\" published=\"\"/>"
echo "  <widget_instances count=\"$count\" thumbnail=\"file:////mnt/usb/www/generic.jpg\">"
file_list=`ls ../html/zchannel/channels.c8/$ID`
 for f in $file_list
 do
echo "<widget_instance id=\"$f\">"
echo "  <name>$f</name>"
echo "  <info updated=\"$xdt\" access=\"private\" secure=\"\" origin=\"manual\" created=\"$xdt\"/>"
tim=`echo 180`
  if [ -f ../html/zchannel/channels.c8/$ID/$f/timeout ]; then
tim=`cat ../html/zchannel/channels.c8/$ID/$f/timeout`
  fi
echo "  <play mode=\"timeout\" time=\"$tim\"/>"
echo "  <rating value=\"0\"/>"
echo "<widget id=\"$f\">"
echo "  <name>$f</name>"
echo "  <description>$f</description>"
echo "  <version>1.0</version>"
echo "  <play mode=\"timeout\" time=\"$tim\"/>"
echo "  <user type=\"community\" id=\"1001001001\" username=\"Zurk\"/>"
echo "  <security sendable=\"false\" previewable=\"false\" access=\"private\" virtualable=\"false\" approval=\"approved\" deletable=\"false\" overlay=\"true\"/>"
echo "  <rating count=\"63\" value=\"4.8889\"/>"
echo "  <thumbnail href=\"http://localhost/zchannel/channels.c8/$ID/$f/thumbnail.jpg\"/>"
echo "  <movie href=\"http://localhost/zchannel/channels.c8/$ID/$f/movie.swf\" contenttype=\"application/x-shockwave-flash\"/>"
echo "  <swfs>"
echo "    <swf width=\"800\" microphone=\"false\" kb=\"false\" camera=\"false\" as_version=\"2\" accelerometer=\"false\" previewable=\"true\" content-type=\"application/x-shockwave-flash\" href=\"http://localhost/zchannel/channels.c8/$ID/$f/movie.swf\" fixed_ar=\"true\" swf_version=\"7\" height=\"600\" bgcolor=\"000000\" supports_browser=\"false\" pointing=\"false\" resolution=\"\" scalable=\"true\" requires_sound=\"true\"/>"
echo "  </swfs>"
echo "</widget>"
echo "  <parameters>"
cat ../html/zchannel/channels.c8/$ID/$f/parameters.txt
echo "  </parameters>"
echo "</widget_instance>"
 done
fi
echo "  </widget_instances>"
echo "</profile>"
