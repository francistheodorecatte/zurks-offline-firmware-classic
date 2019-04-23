#!/bin/sh

echo "<images>" > images.xml
for files in *.jpg
do
	echo "  <image filename=\"$files\" />" >> images.xml
done
echo "</images>" >> images.xml
