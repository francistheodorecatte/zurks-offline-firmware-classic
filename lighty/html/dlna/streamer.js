var upnpsrv = "http://"+window.location.hostname+":9595";
var plsrv = "http://"+window.location.hostname+":5555";
var maxcount = 50;

var fsobj = Object();
fsobj.oid = 0;
fsobj.index = 0;
var browser_stack = [fsobj];
var bstack_ptr = 0;

function init()
{
   $("#add_2_playlist_ntfy").dialog({
			autoOpen: false,
			show: "blind",
			hide: "blind"
		});
   $("#playlist_item_opt").dialog({
			autoOpen: false
		});

   $("button").button();
   $("#browse_btn").click(function(){show_browser()});
   $("#pl_btn").click(function(){show_playlist()});
   $("#trackinfo_btn").click(function(){show_status()});
   $("#play-button").click(function(){player_cmd("play")});
   $("#pause-button").click(function(){player_cmd("pause")});
   $("#stop-button").click(function(){player_cmd("stop")});
   $("#prev-button").click(function(){player_cmd("prev")});
   $("#next-button").click(function(){player_cmd("next")});
   get_status();
   get_playlist();
   browse_devices();
}

function show_browser()
{
   $("#playlist").hide();
   $("#trackinfo").hide();
   $("#browser").show();
}

function show_playlist()
{
   $("#trackinfo").hide();
   $("#browser").hide();
   $("#playlist").show();
}

function show_status()
{
   $("#browser").hide();
   $("#playlist").hide();
   $("#trackinfo").show();
}

function get_playlist()
{
   $.getJSON(plsrv + "/pl/get?jsoncallback=?",show_pl_items);
}

function clear_playlist()
{
   $.get(plsrv + "/pl/clear",function(data){});
   $("#playlist-in").html("");
}

function browse_devices()
{
   $.getJSON(upnpsrv + "/devices?jsoncallback=?",show_devices);
}

function scan_devices()
{
   $("#browser-in").html("<br><br><center><img src=style/images/ajax-loader.gif></center>");
   $.getJSON(upnpsrv + "/scan?jsoncallback=?",show_devices);
}

function show_devices(devobj)
{
   bstack_ptr = 0;
   $("#browser-in").html("<table cellpadding=5px cellspacing=0><tr>");
   $("#browser-in").append("<td><div id='up-button' width=20px class='player-button ui-state-default ui-corner-all' onClick=\"scan_devices()\"><span class='ui-icon ui-icon-refresh'></div>");
   $("#browser-in").append("</table>");
   for(var i in devobj.devices){
      $("#browser-in").append("<div class='browse-device ui-corner-all' onClick=\"browse_upnp('" + devobj.devices[i].id + "',0," + maxcount + ",0)\">" + devobj.devices[i].name + "</div>" );
   }
}


function browse_upnp(server,oid,count,index)
{
   var sobj = new Object();
   sobj.oid = oid;
   sobj.index = index;
   browser_stack[++bstack_ptr] = sobj;
   $.getJSON(upnpsrv + "/browse?device=" + server + "&object=" + oid + "&maxcount=" + count + "&index=" + index + "&jsoncallback=?",
         show_items);
}

function browse_uplevel(server,count)
{
   if (bstack_ptr == 1){
      browse_devices();
      return;
   }
   var sobj = browser_stack[--bstack_ptr];
   
   $.getJSON(upnpsrv + "/browse?device=" + server + "&object=" + sobj.oid + "&maxcount=" + count + "&index=" + sobj.index + "&jsoncallback=?",
         show_items);
}

function show_items(itemsobj)
{
   $("#browser-in").html("<table cellpadding=5px cellspacing=0><tr>");
   $("#browser-in").append("<td><div id='home-button' width=20px class='player-button ui-state-default ui-corner-all' onClick=\"browse_devices()\"><span class='ui-icon ui-icon-home'></div>");   
   $("#browser-in").append("<td><div id='up-button' width=20px class='player-button ui-state-default ui-corner-all' onClick=\"browse_uplevel('" + itemsobj.device + "'," + maxcount + ")\"><span class='ui-icon ui-icon-circle-arrow-n'></div>");
   if (parseInt(itemsobj.index) > 0){
      $("#browser-in").append("<td><div id='up-button' width=20px class='player-button ui-state-default ui-corner-all' onClick=\"browse_upnp('" + itemsobj.device + "','" + itemsobj.object + "'," + maxcount + "," + (parseInt(itemsobj.index) - maxcount) + ")\"><span class='ui-icon ui-icon-circle-arrow-w'></div>");
   }
   if (itemsobj.items.length == maxcount){
      $("#browser-in").append("<td><div id='up-button' width=20px class='player-button ui-state-default ui-corner-all' onClick=\"browse_upnp('" + itemsobj.device + "','" + itemsobj.object + "'," + maxcount + "," + (parseInt(itemsobj.index) + maxcount) + ")\"><span class='ui-icon ui-icon-circle-arrow-e'></div>");
   }
   $("#browser-in").append("</table>");
   for(var i in itemsobj.items){
      if (itemsobj.items[i].type == "container"){
         $("#browser-in").append("<div class='browse-container ui-corner-all' onClick=\"browse_upnp('" + itemsobj.device + "','" + itemsobj.items[i].id + "'," + maxcount + ",0)\">" + itemsobj.items[i].title + "</div>");
      }
      else{
         var o_name = encodeURIComponent(itemsobj.items[i].title);
         var o_url = encodeURIComponent(itemsobj.items[i].url);
         $("#browser-in").append("<div class='browse-object ui-corner-all' onClick=\"add_2_playlist('"+o_name+"','"+o_url+"')\">" + itemsobj.items[i].title + "</div>");      
      }
   }
}

function show_pl_items(plobj)
{
   if (plobj.items.length == 0)
      return;
   $("#playlist-in").html("<table cellpadding=5px cellspacing=0><tr>");
   $("#playlist-in").append("<td><div id='up-button' width=20px class='player-button ui-state-default ui-corner-all' onClick=\"clear_playlist()\"><span class='ui-icon ui-icon-circle-close'></div>");
   $("#playlist-in").append("</table>");
   for(var i in plobj.items){
      $("#playlist-in").append("<div id=pl_index_" + i +" class='pl-item ui-corner-all' onClick=\"playlist_item_opt(" + i + ")\">" + plobj.items[i].name + "</div>");
   }
}

function add_2_playlist_ntfy()
{
   $("#add_2_playlist_ntfy").dialog("open");
   setTimeout('$("#add_2_playlist_ntfy").dialog("close")',1500);
}

function add_2_playlist(oname,ourl)
{
   $.getJSON(plsrv + "/pl/add?name=" + oname + "&url=" + ourl + "&jsoncallback=?", function(data){
                                                                                  show_pl_items(data);
                                                                                  add_2_playlist_ntfy();
                                                                               });
}

function remove_from_playlist(index)
{
   $.getJSON(plsrv + "/pl/remove?index=" + index + "&jsoncallback=?", show_pl_items);
   $("#playlist_item_opt").dialog("close").html("");
}

function playlist_item_opt(index)
{
   $("#playlist_item_opt").html("<button id=play_item_btn onClick=\"play_index(" +
                                 index + ")\">Play</button><button id=remove_item_btn onClick=\"remove_from_playlist(" +
                                 index + ")\">Remove</button>");
   $("#playlist_item_opt").dialog("open");
}

function play_index(index)
{
   player_cmd("playindex?index=" + index);
   $("#playlist_item_opt").dialog("close").html("");
}

function player_cmd(cmd)
{
   $.get(plsrv +"/player/" + cmd,function(data){});
}

function show_status_data(stobj)
{

   $("#status").html(stobj.status + " " + stobj.timecode);
   $('.pl-item-playing').removeClass('pl-item-playing').addClass('pl-item');
   $('#pl_index_' + stobj.plpos).removeClass('pl-item').addClass('pl-item-playing');
   if (stobj.streaminfo.size == undefined){
      $("#trackinfo-in").html("");
   }
   else{   
      $("#trackinfo-in").html("<table>");
      $("#trackinfo-in").append("<tr><td>Track name:<td>" + stobj.track);
      $("#trackinfo-in").append("<tr><td>Play List Position:<td>" + stobj.plpos);
      $("#trackinfo-in").append("<tr><td>Size:<td>" + stobj.streaminfo.size);
      $("#trackinfo-in").append("<tr><td>Duration:<td>" + stobj.streaminfo.duration);
      $("#trackinfo-in").append("<tr><td>Sample Rate:<td>" + stobj.streaminfo.sampleRate);
      $("#trackinfo-in").append("<tr><td>Channels:<td>" + stobj.streaminfo.channelCount);
      $("#trackinfo-in").append("<tr><td>File Type:<td>" + stobj.streaminfo.dataType);
      $("#trackinfo-in").append("</table>");
   }
   setTimeout(get_status,1000);
}

function get_status()
{
   $.getJSON(plsrv + "/player/status?jsoncallback=?",show_status_data);
}

