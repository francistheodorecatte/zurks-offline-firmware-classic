#!/bin/sh

# This script gets executed at the factory to print those nice barcodes you
# see on the outside of the boxes.  We plug in a SII Smart Label Printer 450,
# then generate all of this information, convert the pair of PNG images to
# a raster format specific to the label printer, and send it out the
# parallel port.
# This script gets invoked by a udev rule, located in 98-chumby-late.rules,
# so if you happen to want to do something with that model of printer on a
# chumby, you'll need to remove the corresponding line in that file that
# runs this script.

. /etc/profile
PATH=$PATH:/usr/chumby/scripts
/usr/chumby/scripts/guidgen.sh         > /tmp/guid.txt

/usr/chumby/scripts/chumby_version -n >> /tmp/barcode.txt
echo '|'                              >> /tmp/barcode.txt
/usr/chumby/scripts/chumby_version -h >> /tmp/barcode.txt
echo '|'                              >> /tmp/barcode.txt
/usr/chumby/scripts/chumby_version -s >> /tmp/barcode.txt
echo '|'                              >> /tmp/barcode.txt
/usr/chumby/scripts/chumby_version -f >> /tmp/barcode.txt
echo '|'                              >> /tmp/barcode.txt
dcid -o | md5sum  | cut -d' ' -f1     >> /tmp/barcode.txt
echo '|'                              >> /tmp/barcode.txt
dcid -o                               >> /tmp/barcode.txt

zint --secure=3 --rotate=90 -o /tmp/barcode.png -b 58 -d "$(cat /tmp/barcode.txt)"
zint --secure=3 --rotate=90 -o /tmp/guid.png    -b 58 -d "$(cat /tmp/guid.txt)"
rasterize-label /tmp/guid.png /tmp/barcode.png > /dev/usb/lp0
rm -f /tmp/guid.png /tmp/guid.txt /tmp/barcode.png /tmp/barcode.txt

# Give the printer time to feed the label.
sleep 3

# Let the flash player know we've printed the label.
touch /tmp/label-printed
