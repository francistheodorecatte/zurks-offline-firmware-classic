// AS 3.0?
// import flash.events.MouseEvent;
// import flash.events.Event;

class PhotoFrame extends MovieClip {
  // var debug = true;
  var debug = false;
  var debug_show = false;

  // Top bar: status
  var status_tf:TextField;
  var status_tf_rect:MovieClip;

  // Bottom bar: debug
  var debug_tf:TextField;
  var debug_tf_rect:MovieClip;

  // Image data.
  var images_xml:XML = new XML();
  var images_xml_loading = false;
  var images_xml_loaded = false;
  var images:Array = new Array();
  var images_loaded_on;
  var images_i:Number = -1;

  // When to display next image.
  var image_last_at = 0;

  // Initialized at each frame.
  var now = 0;

  var url = "http://www.discarded-ideas.org/files/photoframe-test";

  var delay = 6000;
  var displayFilename = "yes";
  var random = true;

  var mc:MovieClip;
  var image:MovieClip;
  var image_url_prev:MovieClip;

  // Cached images for double-buffering.
  var img_i = 0;
  var img_0:MovieClip;
  var img_1:MovieClip;

  //Class Constructor/Entry Point
  function PhotoFrame() {
    if ( debug ) {
      debug_show = true;
      url = "http://localhost/photoframe/example";
      // random = false;
    }

    if ( _root.config_url     != undefined) url             = _root.config_url;
    if ( _root.config_delay   != undefined) delay           = _root.config_delay;
    if ( _root.config_display != undefined) displayFilename = _root.config_display;

    Object.registerClass("bgImage", MovieClip);
    attachMovie("bgImage", "background", 0);

    if ( ! debug && 
	 ! (_root.config_url != undefined) && (_root.config_delay != undefined) ) {
      setStatusText("Please configure the widget first.");
    }
  }

  function setStatusText(text:String) {
    if ( ! status_tf ) {
      createTextField("status_tf", 3, 0, -2, 800, 15);
      var fmt:TextFormat = new TextFormat();
      fmt.color = 0x000000;
      fmt.size = 9;
      fmt.font = "Arial";
      fmt.align = "right";
      status_tf.setTextFormat(fmt);

      createEmptyMovieClip("status_tf_rect", 2);
      status_tf_rect.beginFill(0xFFFFFF, 60);
      status_tf_rect.moveTo(0, 0);
      status_tf_rect.lineTo(800, 0);
      status_tf_rect.lineTo(800, 10);
      status_tf_rect.lineTo(0, 10);
      status_tf_rect.endFill();
    }
    if ( text == undefined ) {
      status_tf._visible = false;
      status_tf_rect._visible = false;
    } else {
      status_tf.text = text;
      status_tf._visible = false;
      status_tf_rect._visible = false;
    }
  }

  function setDebugText(text:String) {
    if ( ! debug_show ) return;

    if ( ! debug_tf ) {
      createTextField("debug_tf", 3, 0, 523, 800, 20);
      var fmt:TextFormat = new TextFormat();
      fmt.color = 0x000000;
      fmt.size = 9;
      fmt.font = "Arial";
      fmt.align = "right";
      debug_tf.setTextFormat(fmt);

      createEmptyMovieClip("debug_tf_rect", 2);
      debug_tf_rect.beginFill(0xFFFFFF, 60);
      debug_tf_rect.moveTo(0, 525);
      debug_tf_rect.lineTo(800, 525);
      debug_tf_rect.lineTo(800, 600);
      debug_tf_rect.lineTo(0, 600);
      debug_tf_rect.endFill();
    }
    if ( text == undefined ) {
      debug_tf._visible = false;
      debug_tf_rect._visible = false;
    } else {
      debug_tf.text = text;
      debug_tf._visible = true;
      debug_tf_rect._visible = true;
    }
  }


  function onRelease() {
    images_i += 1;
    showImage();
    // setDebugText("onRelease(): i=" + images_i + ", N=" + images.length);
  }

  // Called on each frame
  function onEnterFrame() {
    // Not ready yet for another image?
    var date = new Date();
    now = date.getTime();
    var countdown = now - image_last_at;
    if ( countdown < delay ) {
      setDebugText("" + images_i + "/" + images.length + " now=" + now + " cd=" + countdown + " d=" + delay);
      return;
    }

    if ( images.length > 0 ) {
      images_i += 1;
      showImage();
    } else {
      loadImages();
    }
  };

  function showImage() {
    var image = getImage();
    if ( image ) {
      var imageUrl = url + "/" + image;

      if (displayFilename != "no") {
	setStatusText("" + (images_i + 1) + "/" + images.length + " " + imageUrl);
      } else {
	setStatusText(undefined);
      }

      // Flip to next img_X.
      var img_i_next = (img_i + 1) % 2;
      mc = createEmptyMovieClip("img_" + img_i_next, 0);
      img_i = img_i_next;

      // Load image into mc.
      mc.loadMovie(imageUrl);

      // Scale and position it.
      scaleImage(320, 240);

      // Make it visible.
      mc.swapDepths(1);

      // Wait until next time.
      image_last_at = new Date();
      image_last_at = image_last_at.getTime();
 
      // setDebugText("i=" + images_i + " N=" + images.length + " r=" + random + " img=" + image + " L=" + images_loaded_on);
      setDebugText(" L=" + images_loaded_on + " il=" + image_last_at);
    }
  }


  function scaleImage(width:Number, height:Number) {
    var scaleX:Number = Math.min(1, width / mc._width);
    var scaleY:Number = Math.min(1, height / mc._height);
    var scale:Number = Math.min(scaleX, scaleY);
    if ( scale != 1 ) {
      mc._xscale  = scale * 100;
      mc._yscale = scale * 100;
    }
    //setStatusText("w/h/s: "+mc._width+"/"+mc._height+"/"+scale);
    //mc._x = (width - mc._width) / 2;
    //mc._y = (height - mc._height) / 2;
  }


  function getImage() {
    var image_url;

    if ( images_i >= images.length ) {
      if ( startLoadImages(true) )
	return;
      if ( loadImages() ) {
	return;
      }

      /* Start at beginning again. */
      images_i = 0;

      if ( random ) {
	/* Avoid repeating the previous image, if randomized. */
	image_url = images[images_i];    
	while ( images.length > 1 && image_url == image_url_prev ) {
	  images_i = (images_i + 1) % images.length;
	  image_url = images[images_i];
	}
      }
    }

    if ( images.length <= 0 ) {
      if ( loadImages() ) {
	return;
      }
      return;
    }

    while ( images_i < 0 ) {
      images_i += images.length;
    }

    image_url = images[images_i];

    image_url_prev = image_url;
    return image_url;
  }


  function loadImages(force) {
    // Loading has not yet started or it is active?
    if ( startLoadImages(false) ) {
      return true;
    }

    var node:Object = images_xml.firstChild;
    var nodes:Object = node.childNodes;
    // random = node.attributes;
    random = node.attributes.random;
    random = random != "no"
    // random = node.attributes.keys
    // random = node.nodeName;

    // setDebugText("Images " + nodes.length);

    images = new Array();
    for ( var i = 0; i < nodes.length; i ++ ) {
      var img_url = nodes[i].attributes.filename;
      if ( img_url != undefined ) {
	images.push(img_url);
      }
    }

    // setDebugText("Images loaded: " + images.length);

    // Ready for loading next time.
    images_xml_loaded = false;
    images_xml_loading = false;
    
    var date = new Date();
    images_loaded_on = date.getTime() / 1000;
      
    // Randomize images Array.
    if ( random ) {
      for ( var i = 0; i < images.length; ++ i ) {
	var r = Math.floor(Math.random() * images.length);
	// setDebugText("i=" + i + ", r=" + r)
	var temp = images[i];
	images[i] = images[r];
	images[r] = temp;
      }
    }

    // Continue.
    return false;
  }

 
  function startLoadImages(force) {
    // Force loading images.
    if ( force && ! images_xml_loading ) {
      images_xml_loaded = false;
    }

    // If the images_xml is already loaded, continue processing it.
    if ( images_xml_loaded ) {
      return false;
    }
    
    // If images.xml is loading, 
    //   Check to see if its finished.
    //   If so, continue processing it.
    //   Otherwise, it is still being loaded.
    if ( images_xml_loading ) {
      if ( images_xml.loaded ) {
	images_xml_loaded = true;
	return false;
      }
      
      return true;
    }

    images_xml_loading = true;
    images_xml_loaded = false;
    // images.length = 0;
      
    images_xml.ignoreWhite = true;
    var xml_url = url + "/images.xml";
    setStatusText("Loading " + xml_url);
    images_xml.load(xml_url);

    return true;
  }

}
