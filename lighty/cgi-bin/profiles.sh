#!/bin/sh
ID=`echo "$QUERY_STRING" | awk -F= '{print $2}' | awk -F'&' '{print $1}' | sed -e 's/%2C//g' |  sed -e 's/%20//g'`
if [ -f "../html/xml/profiles/profiles${ID}" ]
then
cat "../html/xml/profiles/profiles${ID}"
else
cat "../html/xml/profiles/profiles0"
fi




