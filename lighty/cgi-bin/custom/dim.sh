#!/bin/sh
echo "HTTP/1.1 200 ok"
echo "Content-type:  text/html"
echo ""
echo 0 > /proc/sys/sense1/dimlevel
sleep 1
echo 1 > /proc/sys/sense1/dimlevel

