#!/bin/sh      

echo "Content-type: text/html"                                                  
echo ""
echo "<html><head>"
echo "<title>Chumby Multi-Channel Widget Editor</title>"
echo "</head>"
echo "<body>"
echo "<h4>Zurk's Multi Channel Widget Editor</h4><form name=\"spark\">"
echo "Refreshing channel list"
sync
killall chumbyflashplayer.x
rm -f /mnt/storage/widgetcache/*
sync
echo "</form></body></html>"
