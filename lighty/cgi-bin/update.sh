#!/bin/sh

echo "HTTP/1.1 200 ok"
echo "Content-type:  text/xml"
echo ""
if [ -f /psp/c1 ]; then
echo '<?xml version="1.0" encoding="UTF-8"?>'
echo '<update hw="10.7" fw="1.0.1454" config="falconwing" lang="en_US" sw="1.0.6">'
echo '  <none/>'
echo '</update>'
else
echo '<?xml version="1.0" encoding="UTF-8"?>'
echo '<update hw="9.7" fw="1.8.1883" config="opus" lang="en_US" sw="1.8.1">'
echo '  <none/>'
echo '</update>'
fi



