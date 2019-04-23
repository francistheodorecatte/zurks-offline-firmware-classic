#!/bin/sh
#
# cpi.sh - interface with the 'cpi' command line, in a persistent
#          manner that is resilient to errors.
#
# Aaron "Caustik" Robinson
# Copyright (c) Chumby Industries 2007-8
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

TMPBASE=/tmp/cpi-
TMPOUT=${TMPBASE}$$-out.txt
TMPERR=${TMPBASE}$$-err.txt

cpi $@ 1> ${TMPOUT} 2> ${TMPERR}
cpi_res=$?

# if cpi returned a result of '2', it is because it has detected a
# fatal hang. This means we need to reset the serial interface and
# try running cpi again. @todo limit this to N tries?
if [ -e /proc/sys/sense1/resetSerial ]; then
    while [ "$cpi_res" -eq "2" ]; do
        echo "1" > /proc/sys/sense1/resetSerial
        cpi $@ 1> ${TMPOUT} 2> ${TMPERR}
        cpi_res=$?
    done
elif [ "${CNPLATFORM}" = "falconwing" ]
then
    while [ "$cpi_res" -eq "2" ]; do
        sleep 1
        cpi $@ 1> ${TMPOUT} 2> ${TMPERR}
        cpi_res=$?
    done
fi

# in success scenario, output cpi's result
if [ "$cpi_res" -eq "0" ]; then
    cat ${TMPOUT}
fi

# cleanup temporary files
rm -f ${TMPOUT} ${TMPERR}
