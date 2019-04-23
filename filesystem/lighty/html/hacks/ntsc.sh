#!/bin/sh
KRN=krnB
if grep -q mmcblk0p2 /proc/cmdline; then KRN=krnA; fi
cd /mnt/storage
rm -f c1-k1-video switch_output
wget http://files.chumby.com/hacks/c1-k1-video
wget http://files.chumby.com/hacks/switch_output
chmod a+x switch_output
if [ "$(md5sum c1-k1-video | awk '{print $1}')" != "932523d6458abdfc2e7546bcb1c49587" ]
then
    echo "MD5 error.  Cannot continue."
    exit
fi
config_util --cmd=putblock --dev=/dev/mmcblk0p1 --block=${KRN} < /mnt/storage/c1-k1-video
echo "Kernel updated.  Reboot to use it."

stop_control_panel
/mnt/storage/switch_output -n
chumbyflashplayer.x -x 720 -y 480 -i /tmp/controlpanel.swf


