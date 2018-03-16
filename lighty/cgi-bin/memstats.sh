#!/bin/sh
# $Id: memstats 3072 2007-11-16 23:21:44Z ken $
echo "Content-type: text/html" 
echo ""
echo "<html><head>"
FLASHPID=fp
RETURN=/
if [ "${PATH_INFO}" != "" ]
then
        # Get pid and optional return
        FLASHPID="$(echo \"${PATH_INFO}\" | awk -F/ '{print $2;}' | tr -d '`$')"
        RETURN="$(echo \"${PATH_INFO}\" | awk -F/ '{print $3;}' | tr -d '`$')"
else
	echo "empty PATH_INFO" >> /tmp/memstats.log
fi
[ "${FLASHPID}" = "fp" ] && FLASHPID=$(cat /var/run/chumbyflashplayer.pid)
echo "<title>Memory stats for process ${FLASHPID}</title>"
#echo "<meta http-equiv=\"Refresh\" content=\"5\";>"
echo "</head></html>"
echo "<body>"
echo "<h4>Memory stats for process ${FLASHPID}</h4>"

echo "<a href=\"/${RETURN}\">back</a>"
echo "<pre>"
echo "/proc/${FLASHPID}/maps:"
cat /proc/${FLASHPID}/maps
echo "</pre>"
echo "<hr/>"
echo "<pre>"
echo "/proc/${FLASHPID}/smaps:"
cat /proc/${FLASHPID}/smaps
echo "</pre>"
echo "<a href=\"/${RETURN}\">back</a>"
echo "</body></html>"

