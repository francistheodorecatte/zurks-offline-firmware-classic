#!/bin/sh
echo "HTTP/1.1 200 ok"
echo "Content-type:  text/html"
echo ""
cp /psp/url_streams /psp/url_streams.$(/bin/date +%Y-%m-%d-%H.%M.%S).bak
echo "${QUERY_STRING}" | sed -e's/%\([0-9A-F][0-9A-F]\)/\\\\\x\1/g' | xargs echo -e > /psp/url_streams


