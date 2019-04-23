#!/bin/sh

if [ -f /psp/c1 ]; then
LD_LIBRARY_PATH=/mnt/usb/swftools/lib /mnt/usb/swftools/bin/jpeg2swf -X 320 -Y 240 -o /mnt/usb/tmp/sat.swf /mnt/usb/tmp/sat*.jpg
rm -f /mnt/usb/tmp/sat*.jpg
else
LD_LIBRARY_PATH=/mnt/usb/swftools/lib /mnt/usb/swftools/bin/jpeg2swf -X 800 -Y 600 -o /mnt/usb/tmp/sat.swf /mnt/usb/tmp/sat*.jpg
rm -f /mnt/usb/tmp/sat*.jpg
fi
