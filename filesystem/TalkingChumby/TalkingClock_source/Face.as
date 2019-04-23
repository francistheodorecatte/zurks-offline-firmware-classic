class Face extends MovieClip {

    var secondHand : MovieClip;
    var minuteHand : MovieClip;
    var hourHand : MovieClip;
    var speak : LoadVars;

    function Face() {
    	System.security.loadPolicyFile(
    	    "http://127.0.0.1/cgi-bin/custom/speak?action=policy");
        speak = new LoadVars();

        beginFill(0x000000);
        lineTo(0, 240);
        lineTo(360, 240);
        lineTo(360, 0);
        lineTo(0, 0);
        endFill();
        
        lineStyle(3, 0x000000);
        drawCircle(this, 160, 120, 115); 
        drawTicks(60, 5, 1);
        drawTicks(12, 10, 2);
        drawTicks(4, 15, 3);
        
        hourHand = _root.attachClassMovie(Hand, "hourHand1", 
            _root.getNextHighestDepth(), [50, 6, 0x000000]);
        minuteHand = _root.attachClassMovie(Hand, "minuteHand1", 
            _root.getNextHighestDepth(), [100, 3, 0x000000]);
        secondHand = _root.attachClassMovie(Hand, "secondHand1", 
            _root.getNextHighestDepth(), [100, 1, 0xFF0000]);
    }

    function onMouseDown() {
        var now = new Date();
	    var h:Number = now.getHours();
	    var m:Number = now.getMinutes();
	    var hours:String = h.toString();
	    var mins:String = m.toString();
	    if (h < 10) {
		    hours = "0" + hours;
	    }
	    if (m < 10) {
		    mins = "0" + mins;
	    }
		
	    speak.onHTTPStatus = function(httpStatus:Number) {
		    trace("Status: " + httpStatus);
	    };
	    var url = "http://127.0.0.1/cgi-bin/custom/speak?action=time&time=" + 
	        hours + ":" + mins;
	    speak.load(url);
    }

    function onEnterFrame() {
	    var now : Date = new Date();

	    var sec : Number = now.getSeconds() + now.getMilliseconds() / 1000;
	    secondHand._rotation = toDegrees(sec, 60);

	    var min:Number = now.getMinutes() + sec/60;
	    minuteHand._rotation = toDegrees(min, 60);

	    var hourWithMin:Number = now.getHours() + min/60.0;
	    hourHand._rotation = toDegrees(hourWithMin, 12);
	}
	
	function toDegrees(val:Number, range:Number) {
		return (360*(val % range))/range;
	}
    
    function drawCircle(mc:MovieClip, x:Number, y:Number, r:Number):Void { 
        mc.beginFill(0xFFFFFF);
        mc.moveTo(x+r, y); 
        mc.curveTo(r+x, Math.tan(Math.PI/8)*r+y, Math.sin(Math.PI/4)*r+x, 
            Math.sin(Math.PI/4)*r+y); 
        mc.curveTo(Math.tan(Math.PI/8)*r+x, r+y, x, r+y); 
        mc.curveTo(-Math.tan(Math.PI/8)*r+x, r+y, -Math.sin(Math.PI/4)*r+x, 
            Math.sin(Math.PI/4)*r+y); 
        mc.curveTo(-r+x, Math.tan(Math.PI/8)*r+y, -r+x, y); 
        mc.curveTo(-r+x, -Math.tan(Math.PI/8)*r+y, -Math.sin(Math.PI/4)*r+x, 
            -Math.sin(Math.PI/4)*r+y); 
        mc.curveTo(-Math.tan(Math.PI/8)*r+x, -r+y, x, -r+y); 
        mc.curveTo(Math.tan(Math.PI/8)*r+x, -r+y, Math.sin(Math.PI/4)*r+x, 
            -Math.sin(Math.PI/4)*r+y); 
        mc.curveTo(r+x, -Math.tan(Math.PI/8)*r+y, r+x, y);
        mc.endFill(); 
    }

    function drawTicks(num : Number, length : Number, width : Number) {
        lineStyle(width); 
        for (var a:Number = 0; a < Math.PI * 2; a = a + (Math.PI * 2 / num)) {
            moveTo(160 + (110 * Math.cos(a)), 120 + (110 * Math.sin(a)));
            lineTo(160 + ((110 - length) * Math.cos(a)), 
                   120 + ((110 - length) * Math.sin(a)));
        }
    }
}
