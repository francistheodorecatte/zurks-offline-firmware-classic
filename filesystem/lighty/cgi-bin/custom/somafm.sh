#!/bin/sh
echo "HTTP/1.1 200 ok"
echo "Content-type:  text/html"
echo ""
wget -c http://somafm.com/startstream=fw/${QUERY_STRING}.pls -O /tmp/${QUERY_STRING}.pls
MYFILE=`grep File1= /tmp/${QUERY_STRING}.pls | cut -d "=" -f2`
echo "<event type=\"UserPlayer\" value=\"play\" comment=\"${MYFILE}\"/>" > /tmp/flashplayer.event
chumbyflashplayer.x -F1 > /dev/null 2>&1       
echo ""
echo ""     
echo "Now playing ${MYFILE}"
rm /tmp/${QUERY_STRING}.pls

