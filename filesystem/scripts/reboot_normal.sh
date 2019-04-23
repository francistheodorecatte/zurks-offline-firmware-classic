#!/bin/sh
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

# set paranoid boot flag/semaphore
echo "Clearing paranoid boot flag"
if /usr/chumby/scripts/is_stormwind
then
	/usr/chumby/scripts/burn_bootflag "RFS1RFS1RFS1RFS1   "
else
	/bin/flash_eraseall -q /dev/mtd7
	nandwrite /dev/mtd7 /usr/chumby/msp_00_64k_no_oob.bin 0x70000
fi

/usr/chumby/scripts/blast_img rebooting.bin 0
/usr/chumby/scripts/blast_img rebooting.bin 1

sync
sync
reboot
