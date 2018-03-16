#!/bin/sh

# Temporarily do the power initialization here.
regutil -w HW_POWER_CTRL_CLR=1



# Disable the 5V brownout detection.  If we don't do this,
# the board will reboot when USB is brought up.
#regutil -w HW_POWER_5VCTRL=0x00000010


# Set bank 0, pin 26 to GPIO.
regutil -w HW_PINCTRL_MUXSEL1_SET=0x00300000

# Set bank 0, pin 26 to not be a pullup
regutil -w HW_PINCTRL_PULL0_CLR=0x04000000

# Write a "0" to bank 0, pin 26, to disable USB.  This ensures a reset.
regutil -w HW_PINCTRL_DOUT0_SET=0x04000000

# Set bank 0, pin 26 to an output pin, which will write out the value.
regutil -w HW_PINCTRL_DOE0_SET=0x04000000

# Re-write a "0" to bank 0, pin 26 again, as per docs pg 39-11.
regutil -w HW_PINCTRL_DOUT0_SET=0x04000000




insmod /drivers/mux.ko
insmod /drivers/usbcore.ko
insmod /drivers/ehci-hcd.ko

# Mount the USB partition if it isn't mounted already
[ $(mount | grep usbfs | wc -l) -gt 0 ] || mount -n -t usbfs none /proc/bus/usb



regutil -w HW_POWER_CTRL_SET=1
