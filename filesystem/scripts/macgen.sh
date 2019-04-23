#!/bin/sh
#
# macgen.sh - outputs wireless NIC hardware address
#
# Duane Maxwell / Ken Steele
# (c) Copyright Chumby Industries 2006-2007
# All rights reserved
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

SCRIPT_ROOT=${CHUMBY_SCRIPTS:-/usr/chumby/scripts}
NETWORK_INTERFACE=`$SCRIPT_ROOT/network_interface "$@"`

IFCONFIG=`ifconfig $NETWORK_INTERFACE 2>&1`

if echo "$IFCONFIG" | grep -q "Device not found"; then
    MAC="00:00:00:00:00:00"
else
    # bring interface up if necessary
    LINK=`ifconfig $NETWORK_INTERFACE|grep UP`;

    if [ -z "$LINK" ]; then
        ifconfig $NETWORK_INTERFACE up
    fi
    MAC=`ifconfig $NETWORK_INTERFACE | grep HWaddr | sed -e 's/^.*HWaddr //'`
fi

echo $MAC
