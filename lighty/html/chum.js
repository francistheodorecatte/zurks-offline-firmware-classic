function Chumby() {this.init();}
Chumby.prototype={
  init: function() {
    var me = this;
    console.log('Streams Script Init');
    $('#add_stream').click(function(){ me.add('', ''); });
    $('#save_stream').click(function(){ me.save(); });
    for(var v=10; v>=0;v--) { $('#volume_player').append('<option value="'+(v*10)+'">'+(v*10)+'%</option>'); }
    $('#volume_player').change(function() { me.sendCmd("MusicPlayer", "setVolume", $(this).val()); });
    $('#stop_player').click(function() { me.sendCmd("MusicPlayer", "stop", ""); });
    this.renderStream();
  },
  sendCmd: function(type, value, comment) {
    var cmd = '<event type="'+type+'" value="'+value+'" comment="'+comment+'"/>';
    console.log(cmd);
    $.ajax({ url: "event?"+cmd });
  },
  renderStream: function() {
    var me = this;
    var streamsDoc = $.parseXML($('#streams_xml').attr('value'));
    $(streamsDoc).find('stream').each(function() {
      me.add($(this).attr('name'), $(this).attr('url'));
    });
    $('#streams p button.delete').click(function() { $(this).parent().remove(); });
    $('#streams p button.play').click(function() { me.play(this); });
  },
  play: function(bt) {
    var url = $(bt).prev().prev().first().attr('value');
    if (url != '') {
      this.sendCmd("UserPlayer", "play", url);
    }
  },
  add: function(name, url) {
    $('#streams').append('<p><input name="name" value="' + name + '" /> <input name="url" value="' + url + '" /> <button class="delete">Delete</button> <button class="play">Play</button></p>');
  },
  save: function() {
    var streams = '';
    $('#streams p').each(function() {
      var params = $(this).children('input[value!=""]');
      if (params.length==2) {
        // var url = $(params[1]).attr('value').replace('&', '&and;');
        var url = $(params[1]).attr('value');
        var ext = url.substring(url.length-3);
        var mimetype = ext == 'm3u' ? "audio/x-mpegurl" : "audio/x-scpls";
        streams += '<stream name="'+$(params[0]).attr('value')+'" url="'+url+'" mimetype="'+mimetype+'" />';
      }
    });
    streams = "<streams>"+streams+"</streams>";
    $.ajax({ url: "save_streams.sh?"+streams });
  }
}
$(document).ready(function() {
  var chum = new Chumby();
});
