#!/bin/sh
# $Id: network_adapter_list.sh 22661 2009-10-21 05:53:23Z scross $
#
# network_adapter_list.sh - enumerate network adapters
# Unless --readonly specified, persists adapters found in /psp/net_adapters
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

READONLY=0
for option in $*
do
  case ${option} in
    --help)	echo "Syntax: $0 [--readonly]"; exit 0	;;
    --readonly)	READONLY=1	;;
    *)		echo "Unknown option ${option}"; exit 1	;;
  esac
done

echo "<network_adapters>"
# Go through the list of current adapters
echo "<adapter if=\"wlan0\" removable=\"0\" type=\"wlan\" hwaddr=\"00:de:ad:be:ef:00\" present=\"1\" />"
echo "<adapter if=\"rausb0\" removable=\"1\" type=\"wlan\" present=\"0\" />"
echo "</network_adapters>"


