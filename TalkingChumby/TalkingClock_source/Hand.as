class Hand extends MovieClip {

    function Hand(length : Number, width : Number, color : Number) {
        this._x = 160;
        this._y = 120;
        this.lineStyle(width, color);
        this.lineTo(0, -length);
    }

}
