#!/bin/sh
# e.g. http://ip.of.chumby/cgi-bin/message.sh?whatever
echo "HTTP/1.1 200 ok"
echo "Content-type:  text/html"
echo ""
echo "${QUERY_STRING}" > ../html/msg.txt
echo "Message set to ${QUERY_STRING}"
echo ""

