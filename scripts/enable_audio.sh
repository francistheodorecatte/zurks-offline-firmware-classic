#!/bin/sh

# Wait for the audio card to be present.
COUNT=0
while ! amixer get DAC > /dev/null 2> /dev/null && [ ${COUNT} -lt 5 ]
do
    sleep 1
    COUNT=$((${COUNT}+1))
done


# Determine whether to mute the device or not
if [ -e /psp/mute -a "x$(cat /psp/mute)" = "x1" ]
then
    amixer set DAC '0' off > /dev/null

# Restore the mixer volume.
elif [ -e /psp/volume -a $(head -n 1 /psp/volume | egrep ^[0-9]+$ | wc -l) -eq 1 ]
then
    VOLUME=$(head -n 1 /psp/volume)
    
    # We actually run the mixer from 127-255, because
    # anything below 127 is effectively silent.
    # Since we use percentages, cut /psp/volume in half
    # and add 50%.
    DACVOLUME=$(((-((${VOLUME}-100)*(${VOUME}-100))+15000)/150))
    amixer set DAC "${DACVOLUME}%" on > /dev/null
    amixer set Speaker "${VOLUME}%" on > /dev/null

# Set a reasonable default
else
    amixer -c 0 set DAC '90%' > /dev/null
    amixer -c 0 set Speaker '90%' > /dev/null
fi


# Bring the mixer up
amixer -c 0 set HP '100%' on > /dev/null
amixer -c 0 set Speaker on > /dev/null
