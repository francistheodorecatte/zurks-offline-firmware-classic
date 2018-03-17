#!/bin/sh

rm -f /tmp/output.txt
rm -f /tmp/output.wav
/mnt/usb/TalkingChumby/flite_time $1 >/tmp/output.txt
/mnt/usb/TalkingChumby/flite_cmu_time_awb -f /tmp/output.txt -o /tmp/output.wav
/usr/bin/aplay /tmp/output.wav
rm -f /tmp/output.txt
rm -f /tmp/output.wav
