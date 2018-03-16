#!/bin/sh                                                                                               
# /psp/cgi-bin/setvol                                                                                   
# needs volume as parameter between 0 and 100                                                           
# e.g. http://<ip.of.you.chumby/cgi-bin/custom/setvol?30
#                                           
echo "HTTP/1.1 200 ok"                                                                                  
echo "Content-type:  text/html"                                                                         
echo "<event type=\"MusicPlayer\" value=\"setVolume\" comment=\"${QUERY_STRING}\"/>" > /tmp/flashplayer.event
echo ""                                                                                                 
chumbyflashplayer.x -F1 > /dev/null 2>&1                                                                
echo "Volume set to ${QUERY_STRING}"     

