#!/bin/sh
#
# check_update.sh - legacy check for production OTA update
#
#
# Ken Steele
# Copyright (c) Chumby Industries, 2007-2009
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

HVERSION=$(chumby_version -h)
SVERSION=$(chumby_version -s)
FVERSION=$(chumby_version -f)

GUID=$(guidgen.sh)

update1available=1
update2available=1

# CP sends dcid flattened out into parms (see DCID.as)
DCID_PARMS="$(dcid_getparms)"

UPDATE=$(wget -q -O - "http://update.chumby.com/update/text?id=${GUID}&hw=${HVERSION}&sw=${SVERSION}&fw=${FVERSION}&lang=${LANGUAGE}&${DCID_PARMS}&config=${CONFIGNAME}")

UPDATE1=
UPDATE2=
UPDATE1_MD5=
UPDATE2_MD5=
eval $(echo "${UPDATE}" | awk '/update1:/ {printf "UPDATE1=%s; ", $2;}
/update2:/ {printf "UPDATE2=%s; ", $2;}
/md5_1:/ {printf "UPDATE1_MD5=%s; ", $2;}
/md5_2:/ {printf "UPDATE2_MD5=%s; ", $2;}')


if [ "$UPDATE1" ]; then
	echo $UPDATE1 >/tmp/UPDATE1
    if [ "$UPDATE1_MD5" ]; then
        echo $UPDATE1_MD5 >/tmp/UPDATE1_MD5
    fi
else
	update1available=0;
fi
if [ "$UPDATE2" ]; then
	echo $UPDATE2 >/tmp/UPDATE2
    if [ "$UPDATE2_MD5" ]; then
        echo $UPDATE2_MD5 >/tmp/UPDATE2_MD5
    fi
else
	update2available=0;
fi

logger "$0: got update1available=${update1available} update2available=${update2available}"
echo "<update update1=\"$update1available\" update2=\"$update2available\" />"
