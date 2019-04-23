#!/bin/sh
#
# sync_time.sh - synchronize with network time source
#
# Ken Steele
# Copyright (c) Chumby Industries, 2007-2008
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

OPTS="$*"

if [ ! -e /psp/use_ntp ]; then
    echo 1 >/psp/use_ntp
fi

if [ "$(cat /psp/use_ntp)" -eq "1" ]; then
    if ps | grep -v grep | grep -q ntpd
    then
        killall ntpd
    fi
    ntpdate pool.ntp.org

	# Disable this functionality for the beta release.
    # Set up a default driftfile if it doesn't exist.
    if [ ! -e /psp/ntp.drift ]
    then
        echo -140.000 > /psp/ntp.drift
    fi

    ntpd -g -x -f /psp/ntp.drift
    echo `date +%s >/tmp/time_update`
fi

/usr/chumby/scripts/save_time
