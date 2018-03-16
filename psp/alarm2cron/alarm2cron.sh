#!/bin/sh

if [ "/psp/alarms" -nt "/psp/crontabs/root" ] ; then
    (grep -v '# alarm2cron' /psp/crontabs/root; /psp/alarm2cron/alarmparse.pl) | crontab -
fi