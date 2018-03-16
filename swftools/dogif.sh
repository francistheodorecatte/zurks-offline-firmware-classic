#!/bin/sh

LD_LIBRARY_PATH=/mnt/usb/swftools/lib /mnt/usb/swftools/bin/gif2swf -X 320 -Y 240 -o /tmp/gif.swf /tmp/anim.gif
rm -f /tmp/anim.gif

