#!/bin/sh
# $Id: switch_fb.sh 53247 2010-07-16 20:45:44Z scross $
#
# switch_fb.sh - Switch frame buffer visibility to specified (0 or 1)
#
# Henry Groover
# Copyright (c) Chumby Industries, 2008
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA

FBNUM=0
[ "$1" = "" ] || FBNUM=$1

case ${CNPLATFORM}x in
 falconwingx)
        echo "Switching to fb${FBNUM}"
		KEY_EN=0
		ALPHA=0
		FB2_ALPHA=0
		FB3_ALPHA=0
        if [ ${FBNUM} = 1 ]; then
		    ALPHA=255
        elif [ ${FBNUM} = 2 ]; then
		    FB2_ALPHA=255
        elif [ ${FBNUM} = 3 ]; then
		    FB3_ALPHA=255
        else
		    true
        fi
		[ -e /proc/driver/chumbyfwfb/key_en ]    && echo ${KEY_EN} > /proc/driver/chumbyfwfb/key_en
		[ -e /proc/driver/chumbyfwfb/alpha ]     && echo ${ALPHA} > /proc/driver/chumbyfwfb/alpha
		[ -e /proc/driver/chumbyfwfb/fb2_alpha ] && echo ${FB2_ALPHA} > /proc/driver/chumbyfwfb/fb2_alpha
		[ -e /proc/driver/chumbyfwfb/fb3_alpha ] && echo ${FB3_ALPHA} > /proc/driver/chumbyfwfb/fb3_alpha
        ;;
 stormwindx)
	echo "Switching to fb${FBNUM}"
	if [ ${FBNUM} = 0 ]; then
		# Enable win0
		echo 0x10415 > /proc/driver/s3regs/lcd_wincon0
		# Turn off alpha
		echo 0x0 > /proc/driver/s3regs/lcd_win1alpha1
	else
		# Enable win1
		echo 0x10417 > /proc/driver/s3regs/lcd_wincon1
		# Turn on alpha
		echo 0xfff > /proc/driver/s3regs/lcd_win1alpha1
	fi
	;;
 silvermoonx)
	echo "switching to fb${FBNUM}"
	if [ ${FBNUM} = 0 ]; then
		cat /dev/zero > /dev/fb1 2> /dev/null
	fi
	;;
 *)	echo "Don't know how to handle CNPLATFORM=\"${CNPLATFORM}\""
	;;
esac

