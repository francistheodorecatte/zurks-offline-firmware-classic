
class PhotoFrameConfig extends MovieClip {

  // globally accessable variables for the text fields and the button
  var tf:TextField;
  var inputDelay:TextField;
  var inputURL:TextField;
  var inputDisplay:TextField;
  var btn:MovieClip;

  // The function _chumby_got_widget_parameters is called twice; one time before you
  // edit the values and one time immediately before exiting. The sample code used the
  // callback parameter to apply the function that should be called after
  // _chumby_got_widget_parameters finished it's job; but that didn't work for me
  // somehow, so I used this workaround.
  var about_to_exit:Boolean;


  // Class Constructor/Entry Point
  // This initializes the GUI stuff, fetches the configuration... and tells the program
  // that we still want to do something afterwards.
  function PhotoFrameConfig() {
    initialize();
    about_to_exit = false;
    _chumby_get_widget_parameters(gotParameters);
  }

  // set the contents of the non-editable TextField
  // for some reason, I have to re-create it every time I change the text,
  // otherwise it just stays empty.
  function setText(text:String) {
    createTextField("tf", 1, 10, 10, 298, 160);
    tf = this["tf"];
    tf.text = text;
    tf.multiline = true;
    tf.bold = true;
    var fmt:TextFormat = new TextFormat();
    fmt.color = 0x000000;
    fmt.size = 12;
    fmt.font = "Arial";
    tf.setTextFormat(fmt);
  }

  // Taken directly from the sample code.
  // This function fetches the widget parameters from the Chumby network.
  // The callback parameter is simply passed on to the next function -
  // I don't use it anywhere in the code, but if I take it out, the
  // widget refuses to work.
  function _chumby_get_widget_parameters(callback) {
    var _chumby_xml = new XML();
    _chumby_xml.target = this;
    _chumby_xml.callback = callback;
    _chumby_xml.onLoad = function() {
      this.target._chumby_got_widget_parameters(callback,this.firstChildOfType("widget_instance"));
	  }
    _chumby_xml.load(_root._chumby_instance_url);
  }

  // Taken from the sample code.
  // This parses the XML text that is retrieved from the Chumby network and
  // which holds the widget's parameters. The XML looks like this:
  // <widget_instance id="...">
  //  <widget_parameters>
  //    <widget_parameter>
  //      <name>parameter name</name>
  //      <value>parameter value</name>
  //    </widget_parameter>
  //  </widget_parameters>
  // <widget_instance>
  // Instead of the callback function (like in the original sample code),
  // I use the variable "about_to_exit" to determine which function to call
  // afterwards.
  function _chumby_got_widget_parameters(callback,x) {
    var widget_params = x.firstChildOfType("widget_parameters");
  	widget_params = widget_params.childrenOfType("widget_parameter");
    var p = {}
  	for (var i in widget_params) {
      var widget_param = widget_params[i];
      var key = widget_param.firstChildOfType("name").firstChild.nodeValue;
  		var value = widget_param.firstChildOfType("value").firstChild.nodeValue;
      p[key] = value;
  	}
  	if (about_to_exit) {
      _chumby_exit();
    }
    else gotParameters(p);
  }


  // Taken directly from the sample code.
  // This packs the parameters into a neat XML package and sends it off to the
  // Chumby network. Obviously, before calling this, the user should get a chance to
  // change some of the values.
  function _chumby_set_widget_parameters(callback,p) {
  	var _chumby_xml = new XML();
    _chumby_xml.onLoad = undefined;
  	var widget_parameters_xml = _chumby_xml.createElement("widget_parameters");
    for (var i in p) {
		  var widget_parameter_xml = _chumby_xml.createElement("widget_parameter");
  		var name_xml = _chumby_xml.createElement("name");
      name_xml.appendChild(_chumby_xml.createTextNode(i));
      var value_xml = _chumby_xml.createElement("value");
      value_xml.appendChild(_chumby_xml.createTextNode(p[i]));
      widget_parameter_xml.appendChild(name_xml);
      widget_parameter_xml.appendChild(value_xml);
  		widget_parameters_xml.appendChild(widget_parameter_xml);
    }
  	var widget_instance_xml = _chumby_xml.createElement("widget_instance");
    widget_instance_xml.appendChild(widget_parameters_xml);
    _chumby_xml.appendChild(widget_instance_xml);
    var _chumby_result_xml = new XML();
  	_chumby_result_xml.target = this;
    _chumby_result_xml.callback = callback;
  	_chumby_result_xml.onLoad = function() {
    this.target._chumby_got_widget_parameters(callback,this.firstChildOfType("widget_instance"));
    }
  	_chumby_xml.sendAndLoad(_root._chumby_instance_url,_chumby_result_xml);
  }

  // Taken directly from the sample code - including the following comment. :-)
  // Call this function to dismiss the dialog - it tells the hosting webpage to remove the movie from the page
  function _chumby_exit() {
    getURL("javascript:dismiss()");
  }

  // Taken from the sample code.
  // After retrieving the parameters, set the text fields according to the relevant ones,
  // config_delay and config_url.
  function gotParameters(x) {
  	_root.params = x;
    if (_root.params["config_delay"] != undefined) inputDelay.text = _root.params["config_delay"];
    if (_root.params["config_url"] != undefined) inputURL.text = _root.params["config_url"];
    if (_root.params["config_display"] != undefined) inputDisplay.text = _root.params["config_display"];
  }

  // This is called when the (horribly drawn) button is pressed.
  // the params are set to the values of the corresponding text fields
  // and then sent to Chumby via _chumby_get_widget_parameters.
  function buttonAction() {
    setText("Thank you!\n\nDelay (milliseconds)\n\n\nURL");
  	_root.params["config_delay"] = inputDelay.text;
    _root.params["config_url"] = inputURL.text;
    _root.params["config_display"] = inputDisplay.text;
    about_to_exit = true;
  	_chumby_set_widget_parameters(_chumby_exit,_root.params);
  }

  function initialize() {

    // Okay, now this is kinda dirty... but I took this from the sample code, too.
    // From what I gathered, these two are XML-related functions that are
    // injected into the base object class. I tried to add them to the XML
    // class instead, but nextSibling returns an XMLNode object, so I would have
    // had to change that as well - too much black magic for a Flash noob like me.
    Object.prototype.childrenOfType = function(s,a) {
      if (a == undefined) {
        a = new Array();
      }
      var n = this.firstChild;
      while (n) {
        if (n.nodeName==s) {
          a.push(n);
        }
        n = n.nextSibling;
      }
      return a;
      }

    Object.prototype.firstChildOfType = function(s) {
      var n = this.firstChild;
      while (n) {
        if (n.nodeName==s) {
          return n;
        }
        n = n.nextSibling;
      }
    return null;
    }

    // set the main text
    setText("PhotoFrame Widget configuration\n\nDelay (milliseconds)\n\n\nURL\n\n\nDisplay file names");

    // create and format the two input text fields
    createTextField("inputDelay", 2, 10, 60, 298, 20);
    inputDelay = this["inputDelay"];
    inputDelay.type = "input";
    inputDelay.border = true;
    inputDelay.text = "6000";

    createTextField("inputURL", 3, 10, 100, 298, 20);
    inputURL = this["inputURL"];
    inputURL.border = true;
    inputURL.type = "input";
    inputURL.text = "http://www.discarded-ideas.org/files/photoframe-test";

    createTextField("inputDisplay", 4, 10, 140, 298, 20);
    inputDisplay = this["inputDisplay"];
    inputDisplay.border = true;
    inputDisplay.type = "input";
    inputDisplay.text = "yes";

    var my_fmt:TextFormat = new TextFormat();
    my_fmt.color = 0xffffff;
    my_fmt.size = 15;
    my_fmt.font = "Arial";
    inputDelay.setTextFormat(my_fmt);
    inputURL.setTextFormat(my_fmt);
    inputDisplay.setTextFormat(my_fmt);

    // register the testButton as a MovieClip, which is actually
    // used as a button. The "testButton" object is defined
    // in the XML input for swfmill.
    // the onRelease function of the button is configured to call
    // this class' buttonAction() function.
    Object.registerClass("testButton", MovieClip);
    attachMovie("testButton", "btn", 5);
    btn._x = 100;
    btn._y = 180;
    btn._parent = this;
    btn.onRelease = function() { this._parent.buttonAction() };
  }

}
