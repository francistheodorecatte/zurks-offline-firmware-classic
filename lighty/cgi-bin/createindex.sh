#!/bin/sh

cd /mnt/usb/lighty/html/photos
  echo "<images>"
  for files in *.jpg
  do
    echo "  <image filename=\"$files\" />" 
  done
  echo "</images>"

