#!/bin/sh

# Write a "0" to bank 0, pin 26, to disable USB.  This ensures a reset.
regutil -w HW_PINCTRL_DOUT0_CLR=0x04000000

# Sleep, to let the USB subsystem settle, so the devices know they'll
# need to get a new address.  1 second is too short a time for some USB
# devices (e.g. the rt73 sometimes doesn't reappear.)
sleep 2

# Finally, enable power to the USB root device.
regutil -w HW_PINCTRL_DOUT0_SET=0x04000000
