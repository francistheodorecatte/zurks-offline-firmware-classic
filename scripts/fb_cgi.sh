#!/bin/sh
#
# fb_cgi.sh - set up frame buffer access via http
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


# Default rate is 5s - allow override
REFRESH_RATE=5
[ "$1" ] && REFRESH_RATE=$1

# Default quality is 100 - allow override
QUALITY=100
[ "$2" ] && QUALITY=$2

make_script()
{
  FB=$1
  RATE=$2
  Q=$3
  SCRIPT=/tmp/fb${FB}
  
  echo "#!/bin/sh
echo \"HTTP/1.1 200 ok\"
echo \"Content-type: image/jpeg\"
echo \"Refresh: ${RATE}; #\"
echo \"\"
/usr/bin/imgtool --quality=${Q} --mode=cap --fb=${FB} -" > ${SCRIPT}


  chmod +x ${SCRIPT}

  [ -e /psp/cgi-bin/fb${FB} ] && rm -f /psp/cgi-bin/fb${FB}

  ln -s ${SCRIPT} /psp/cgi-bin/fb${FB}
}

make_script 0 ${REFRESH_RATE} ${QUALITY}
make_script 1 ${REFRESH_RATE} ${QUALITY}

