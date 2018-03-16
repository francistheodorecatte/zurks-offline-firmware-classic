#!/bin/sh
#
# Note
# Edit Pitt+Meadows+BC to whatever country and city code you want to get local weather/Change 71775 to your local station code.
# Make sure the forecast is pulled up when you visit both URLs below to ensure that it works ok. Weather is updated every hour.
# v11 onwards now include a black box if your chumby hangs. post the contents of blackbox.txt and orangebox.txt up when reporting crashes or hangs.
# For USA only the codes can be found as follows :
# you get the numeric id by going to :
# http://www.wunderground.com/cgi-bin/findweather/getForecast?query=natick%2C+ma
# it should show up in recent cities at the top. select the link :
# http://www.wunderground.com/cgi-bin/findweather/getForecast?query=zmw:01760.1.99999
# then copy the numeric station id :
# http://rss.wunderground.com/auto/rss_full/stations/01760.1.99999.xml?units=both
# and that is your numeric station ID and URL.
# alternatively just do a google search for your station and most pop up. In most cases the USA code is the same as your postcode.
# For the rest of the world simply search for your location on wunderground and then click the red rss icon which will give you your code.
# For a weather radar image find a good url on the web and paste it. The url needs to be an animated gif.
# Note that for individual widget weather such as RapidFire, wGraph and Accuweather you need to change the profile file.
# zurk
#
if [ ! -e /tmp/zwapi.lock ]; then
touch /tmp/zwapi.lock
if [ -f /tmp/dlna.on ]; then
rm -f /tmp/dlna.on
# playlist server port 5555
/mnt/usb/streamer/btplserver 5555 &
# UPnP Gateway server on port 9595
/mnt/usb/perl/perl /mnt/usb/streamer/upnphttpgw.pl &
else
sync
fi
echo >/mnt/usb/tmp/access.log
echo >/mnt/usb/tmp/error.log
if [ -f /mnt/usb/autoreboot.on ]; then
count=`dmesg|grep "cut here"|wc -l`
if [ $count -ne 0 ]
then
echo kernel_bug >/mnt/usb/crashbox.txt
date >>/mnt/usb/crashbox.txt
uptime >>/mnt/usb/crashbox.txt
free >>/mnt/usb/crashbox.txt
du -sh /tmp >>/mnt/usb/crashbox.txt
/sbin/ifconfig -a >>/mnt/usb/crashbox.txt
dmesg >>/mnt/usb/crashbox.txt
echo kernel_bug >>/mnt/usb/crashbox.txt
rm -f /tmp/zwapi.lock
sync
/usr/chumby/scripts/reboot_normal.sh
fi
fi
/sbin/ifconfig wlan0 up
ping -q -c2 google.com > /dev/null
if [ $? -eq 0 ]; then
date >/mnt/usb/blackbox.txt
uptime >>/mnt/usb/blackbox.txt
free >>/mnt/usb/blackbox.txt
du -sh /tmp >>/mnt/usb/blackbox.txt
/sbin/ifconfig -a >>/mnt/usb/blackbox.txt
dmesg >>/mnt/usb/blackbox.txt
rm -f /tmp/zwapi.html
rm -f /tmp/x
rm -f /tmp/anim.gif
sync
# MODIFY THE LINES BELOW FOR THE WEATHER ONLY. DO NOT MODIFY ANY OF THE REST OF THE FILE. ENSURE THE URLS WORK BY GOING TO YOUR WEB BROWSER AND LOADING THEM.
curl --silent --output /tmp/zwapi.html "http://m.wund.com/cgi-bin/findweather/getForecast?brand=mobile&query=Pitt+Meadows+BC"
curl --silent --output /tmp/x "http://rss.wunderground.com/auto/rss_full/global/stations/71775.xml?units=both"
curl --silent --output /tmp/0.png "https://radar.weather.gov/ridge/lite/N0R/ATX_7.png"
curl --silent --output /tmp/1.png "https://radar.weather.gov/ridge/lite/N0R/ATX_6.png"
curl --silent --output /tmp/2.png "https://radar.weather.gov/ridge/lite/N0R/ATX_5.png"
curl --silent --output /tmp/3.png "https://radar.weather.gov/ridge/lite/N0R/ATX_4.png"
curl --silent --output /tmp/4.png "http://radar.weather.gov/ridge/lite/N0R/ATX_3.png"
curl --silent --output /tmp/5.png "https://radar.weather.gov/ridge/lite/N0R/ATX_2.png"
curl --silent --output /tmp/6.png "https://radar.weather.gov/ridge/lite/N0R/ATX_1.png"
curl --silent --output /tmp/7.png "https://radar.weather.gov/ridge/lite/N0R/ATX_0.png"
# STOP MODIFYING BELOW THIS LINE. DO NOT MODIFY ANY OF THE REST OF THE FILE.
#wget -q --output-document=/tmp/anim.gif "http://radar.weather.gov/ridge/lite/N0R/ATX_loop.gif"
#sed 's!<link>.*</link>!!g' /tmp/x > /tmp/x2
#sed 's!<pubDate>.*</pubDate>!!g' /tmp/x2 > /tmp/x
#sed 's!<guid.*</guid>!!g' /tmp/x > /tmp/x2
#sed 's/<\/title>//g' /tmp/x2 > /tmp/x
#sed 's/<description>//g' /tmp/x > /tmp/x2
#sed 's/<\/description>/<\/title>/g' /tmp/x2 > /tmp/x
#awk '$1=$1' ORS=' ' /tmp/x >/tmp/x2
#rm -f /tmp/x2
cp /tmp/x /mnt/usb/lighty/html/zurksofw/rss.xml
cp /tmp/x /mnt/usb/lighty/html/zurksofw/rss
rm -f /tmp/x
rm -f /mnt/storage/widgetcache/*
sync
/mnt/usb/java/bin/java -cp /psp zwapi /tmp/zwapi.html /mnt/usb/lighty/html/zurksofw/weather_items
rm -f /tmp/zwapi.html
/bin/sh /mnt/usb/swftools/dopng.sh
date >/mnt/usb/orangebox.txt
uptime >>/mnt/usb/orangebox.txt
free >>/mnt/usb/orangebox.txt
du -sh /tmp >>/mnt/usb/orangebox.txt
/sbin/ifconfig -a >>/mnt/usb/orangebox.txt
dmesg >>/mnt/usb/orangebox.txt
sync
else
if [ -f /mnt/usb/autoreboot.on ]; then
echo no_net >/mnt/usb/crashbox.txt
date >>/mnt/usb/crashbox.txt
uptime >>/mnt/usb/crashbox.txt
free >>/mnt/usb/crashbox.txt
du -sh /tmp >>/mnt/usb/crashbox.txt
/sbin/ifconfig -a >>/mnt/usb/crashbox.txt
dmesg >>/mnt/usb/crashbox.txt
echo no_net >>/mnt/usb/crashbox.txt
rm -f /tmp/zwapi.lock
sync
/usr/chumby/scripts/reboot_normal.sh
fi
fi
rm -f /mnt/storage/widgetcache/*
rm -f /tmp/zwapi.lock
else
echo locked >>/mnt/usb/orangebox.txt
fi
