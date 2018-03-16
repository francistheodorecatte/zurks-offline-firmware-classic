#!/bin/sh

# Set bank 2, pin 8 to GPIO.
regutil -w HW_PINCTRL_MUXSEL4_SET=0x00030000

# Set bank 2, pin 8 to not be a pullup
regutil -w HW_PINCTRL_PULL2_CLR=0x00000100

# Write a "1" to bank 2, pin 8, to enable the regulator
regutil -w HW_PINCTRL_DOUT2_SET=0x00000100

# Set bank 2, pin 8 to an output pin, which will write out the value.
regutil -w HW_PINCTRL_DOE2_SET=0x00000100

# Re-write a "1" to bank 2, pin 8 again, as per docs pg 39-11.
regutil -w HW_PINCTRL_DOUT2_SET=0x00000100

