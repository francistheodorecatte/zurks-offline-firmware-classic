#!/bin/sh

if [ -f /psp/c1 ]; then
LD_LIBRARY_PATH=/mnt/usb/swftools/lib /mnt/usb/swftools/bin/swfc /mnt/usb/swftools/c1png.sc
rm -f /mnt/usb/tmp/0.png
rm -f /mnt/usb/tmp/1.png
rm -f /mnt/usb/tmp/2.png
rm -f /mnt/usb/tmp/3.png
rm -f /mnt/usb/tmp/4.png
rm -f /mnt/usb/tmp/5.png
rm -f /mnt/usb/tmp/6.png
rm -f /mnt/usb/tmp/7.png
else
LD_LIBRARY_PATH=/mnt/usb/swftools/lib /mnt/usb/swftools/bin/swfc /mnt/usb/swftools/c8png.sc
rm -f /mnt/usb/tmp/0.png
rm -f /mnt/usb/tmp/1.png
rm -f /mnt/usb/tmp/2.png
rm -f /mnt/usb/tmp/3.png
rm -f /mnt/usb/tmp/4.png
rm -f /mnt/usb/tmp/5.png
rm -f /mnt/usb/tmp/6.png
rm -f /mnt/usb/tmp/7.png
fi
