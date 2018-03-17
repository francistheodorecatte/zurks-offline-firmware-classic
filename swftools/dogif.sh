#!/bin/sh

if [ -f /psp/c1 ]; then
LD_LIBRARY_PATH=/mnt/usb/swftools/lib /mnt/usb/swftools/bin/gif2swf -X 320 -Y 240 -o /mnt/usb/tmp/sat.swf /mnt/usb/tmp/anim.gif
rm -f /mnt/usb/tmp/anim.gif
else
LD_LIBRARY_PATH=/mnt/usb/swftools/lib /mnt/usb/swftools/bin/gif2swf -X 800 -Y 600 -o /mnt/usb/tmp/sat.swf /mnt/usb/tmp/anim.gif
rm -f /mnt/usb/tmp/anim.gif
fi
