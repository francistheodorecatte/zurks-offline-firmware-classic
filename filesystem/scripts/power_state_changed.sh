#!/bin/sh

. /etc/profile
SHOULD_TELL_FLASH=1
if [ "x$1" = "x-n" ]
then
    SHOULD_TELL_FLASH=0
fi

AC_ONLINE=$(cat /sys/class/power_supply/ac/online)

echo "AC online? ${AC_ONLINE}  Telling flash? ${SHOULD_TELL_FLASH}"


if [ ${AC_ONLINE} -eq 1 ]
then
    for bl in $(/bin/ls --color=never /sys/class/backlight/)
    do
#        echo 100 > /sys/class/backlight/${bl}/max_brightness
    done
#    iwconfig wlan0 power off

    # Restore power to port 1.
#    hub-ctrl -h 0 -P 1 -p 1

else
    MAX_BRIGHTNESS=50
    if [ -e /psp/max_brightness_battery ]
    then
        MAX_BRIGHTNESS=$(cat /psp/max_brightness_battery)
    fi
    
    for bl in $(/bin/ls --color=never /sys/class/backlight/)
    do
#        echo ${MAX_BRIGHTNESS} > /sys/class/backlight/${bl}/max_brightness
    done
    
#    iwconfig wlan0 power on

    # If the connected device draws more than 200mA, cut it off.
    if [ "$(chumby_version -h | cut -d'.' -f2)" -lt "7" ]
    then
        MP=$(cat /sys/class/usb_device/usbdev1.2/device/1-1.1/bMaxPower | tr -d mA)
        if [ $? = 0 -a ${MP} -gt 200 ]
        then
            # Try multiple times to ensure the port is gone.
            # I'd really rather not do this, but if we want to turn the port off
            # as soon as the device is plugged in, it seems as though it will get
            # turned back on, especially if we're dealing with an ipod.
            for i in 1 2 3 4 5 6
            do
#                hub-ctrl -h 0 -P 1 -p
                sleep 1
            done
        fi
    fi
fi


if [ ${SHOULD_TELL_FLASH} = 1 ]
then
    # Tell flash about the change.
    true
fi
