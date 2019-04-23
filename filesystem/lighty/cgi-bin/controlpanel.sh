#!/bin/sh

echo "HTTP/1.1 200 ok"
echo "Content-type:  text/xml"
echo ""
if [ -f /psp/c8 ]; then
echo '<?xml version="1.0" encoding="UTF-8"?>'
echo '<controlpanel build="5.0.35">'
echo '<url>http://localhost/xml/c8/controlpanel.swf</url>'
echo '<compressed>false</compressed>'
echo '<filename>controlpanel.swf</filename>'
echo '<md5>b88da79df15d94d59b7207b5f9c44a59</md5>'
echo '<location>/tmp</location>'
echo '<launchname>controlpanel.swf</launchname>'
echo '<player_parameters/>'
echo '<parameters>'
echo '<parameter value="9999" name="defaultUpdateTime"/>'
echo '<parameter value="9999" name="defaultProfileTime"/>'
echo '</parameters>'
echo '<post_install/>'
echo '</controlpanel>'
else
echo '<?xml version="1.0" encoding="UTF-8"?>'
echo '<controlpanel build="2.8.84">'
echo '<url>http://localhost/xml/c1/controlpanel.swf</url>'
echo '<compressed>false</compressed>'
echo '<filename>controlpanel.swf</filename>'
echo '<md5>81b58e093000695fdd4f2e987c908785</md5>'
echo '<location>/tmp</location>'
echo '<launchname>controlpanel.swf</launchname>'
echo '<player_parameters/>'
echo '<parameters>'
echo '<parameter value="9999" name="defaultUpdateTime"/>'
echo '<parameter value="9999" name="defaultProfileTime"/>'
echo '</parameters>'
echo '<post_install/>'
echo '</controlpanel>'
fi

