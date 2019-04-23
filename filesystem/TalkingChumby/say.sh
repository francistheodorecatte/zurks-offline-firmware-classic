#!/bin/sh

rm -f /tmp/output.wav
/mnt/usb/TalkingChumby/flite_cmu_us_kal16 -t "$1" -o /tmp/output.wav
/usr/bin/aplay /tmp/output.wav
rm -f /tmp/output.wav

