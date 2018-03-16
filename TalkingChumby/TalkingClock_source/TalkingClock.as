class TalkingClock extends MovieClip {

    static var app : TalkingClock;
    var face : MovieClip;
    
    function TalkingClock() {
        face = _root.attachClassMovie(Face, "face1", 
            _root.getNextHighestDepth());
    }

    static function main(mc) {
        // Creates an empty movie and binds it to a MovieClip subclass. 
        // There is no need to have anything on the stage nor in a library.
        //
        // @param className  	a MovieClip subclass
        // @param instanceName	the name that identifies the new movie
        //			(see createEmptyMovieClip)
        // @param depth		the depth to create the movie at
        //			(see createEmptyMovieClip)
        // @param argv		Optional. The subclass constructor parameters
        //			bundled in an Array. (see docs for apply()) Example:
        //          ["arg1", i]
        //
        // Example:
        //
        //    var my_mc:MovieClip = canvas_mc.attachClassMovie(MyMovieSubClass,
        //                              "myClassMovie1", 1);
        MovieClip.prototype.attachClassMovie = function(className:Function,
		                                				instanceName:String,
		                                				depth:Number,
		                                				argv:Array):MovieClip {
        	// Create emptyMovieClip
	        var new_mc:MovieClip = this.createEmptyMovieClip(instanceName, 
	                                                         depth);

        	// Save class prototype
        	new_mc.__proto__ = className.prototype;

        	// apply the constructor
        	className.apply(new_mc, argv);

        	if(new_mc.init)
        		new_mc.init();

	        // return new clip
	        return new_mc;
        }
        app = new TalkingClock();
    }
}
