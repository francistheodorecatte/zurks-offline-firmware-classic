#!/bin/sh
echo "HTTP/1.1 200 ok"
echo "Content-type: image/jpeg"
echo "Refresh: 5; #"
echo ""
/usr/bin/imgtool --quality=100 --mode=cap --fb=1 -
