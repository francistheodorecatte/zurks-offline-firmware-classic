#!/bin/sh

echo "HTTP/1.1 200 ok"
echo "Content-type:  text/xml"
echo ""
if [ -f /psp/c1 ]; then
echo '<MusicSources>'
echo '  <Music can_pause="false" panel="http://music.chumby.com/pandora/pandoraPanel215.swf" can_next="false" alarm_panel="http://music.chumby.com/pandora/pandoraAlarmPanel215.swf" can_prev="false" label="Pandora Radio" can_alarm="true" can_resume="true" id="pandora" player="http://music.chumby.com/pandora/pandoraPlayer215.swf" ver="2.15" position="0"/>'
echo '  <Music can_pause="false" panel="http://music.chumby.com/clearchannel/ihr_panel.swf" can_next="false" alarm_panel="" can_prev="false" label="iheartradio" can_alarm="false" can_resume="true" id="iheartradio" player="http://music.chumby.com/clearchannel/ihr_player.swf" ver="beta 18653" position="2"/>'
echo '</MusicSources>'
else
echo '<MusicSources>'
echo '  <Music panel="http://music.chumby.com/pandora/pandoraPanel800x600.swf" can_next="true" alarm_panel="http://music.chumby.com/pandora/pandoraAlarmPanel800x600.swf" can_prev="false" can_alarm="true" label="Pandora Radio" can_resume="true" id="pandora" player="http://music.chumby.com/pandora/pandoraPlayer_v216.swf" can_pause="true" ver="216" position="1"/>'
echo '  <Music panel="http://music.chumby.com/iheartradio/ihr_panel_800x600_v114.swf" can_next="false" alarm_panel="" can_prev="false" can_alarm="false" label="iheartradio" can_resume="true" id="iheartradio" player="http://music.chumby.com/iheartradio/ihr_player_v114.swf" can_pause="false" ver="1.14" position="2"/>'
echo '</MusicSources>'
fi
