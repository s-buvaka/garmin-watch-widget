import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.WatchUi;

// Loads the dynamic-element art (battery outline, gauge & frame track/fill) and
// provides the progress "reveal": draw track + full fill, then cover the unfilled
// angular part with the empty colour (a thick dark arc). Geometry is measured from
// the assets (see Constants ART_*/*_ANG_*).
module Art {
    var _batt = null;
    var _glT = null; var _glF = null;
    var _grT = null; var _grF = null;
    var _frT = null; var _frF = null;
    var _tried = false;

    function _load() {
        if (_tried) { return; }
        _tried = true;
        try {
            _batt = WatchUi.loadResource(Rez.Drawables.BatteryOutline);
            _glT  = WatchUi.loadResource(Rez.Drawables.GaugeLeftTrack);
            _glF  = WatchUi.loadResource(Rez.Drawables.GaugeLeftFill);
            _grT  = WatchUi.loadResource(Rez.Drawables.GaugeRightTrack);
            _grF  = WatchUi.loadResource(Rez.Drawables.GaugeRightFill);
            _frT  = WatchUi.loadResource(Rez.Drawables.FrameTrack);
            _frF  = WatchUi.loadResource(Rez.Drawables.FrameFill);
        } catch (ex instanceof Lang.Exception) {
        }
    }

    function batteryOutline() { _load(); return _batt; }
    function gaugeLeftTrack()  { _load(); return _glT; }
    function gaugeLeftFill()   { _load(); return _glF; }
    function gaugeRightTrack() { _load(); return _grT; }
    function gaugeRightFill()  { _load(); return _grF; }
    function frameTrack()      { _load(); return _frT; }
    function frameFill()       { _load(); return _frF; }

    // Draw a bitmap whose top-left is (fx, fy) as fractions of screenW.
    function drawAt(dc as Graphics.Dc, bmp, screenW as Number, fx as Float, fy as Float) as Void {
        if (bmp == null) { return; }
        dc.drawBitmap((fx * screenW).toNumber(), (fy * screenW).toNumber(), bmp);
    }

    // Cover the unfilled part of a fill band with emptyColor.
    // progress 0..1. fillFrom = 0% angle, fillTo = 100% angle (Garmin deg). ccw = fill direction.
    // Reveal only the FILLED part (0..progress) of a fill bitmap by blitting it through a
    // moving square clip that walks the band arc. Unfilled part stays transparent (no grey).
    // bmp drawn at top-left (offX,offY)*screenW. geo = [offX, offY, cyFrac, midRfrac, hwFrac].
    // angles = [fillFrom(0%), fillTo(100%)] in Garmin degrees. ccw = fill direction.
    function drawFillArc(dc as Graphics.Dc, screenW as Number, bmp,
                         geo as Array, angles as Array, ccw as Boolean, progress as Float) as Void {
        if (bmp == null || progress <= 0.001) { return; }
        if (progress > 1.0) { progress = 1.0; }

        var ox  = (geo[0] * screenW).toNumber();
        var oy  = (geo[1] * screenW).toNumber();
        var cxp = screenW / 2;
        var cyp = geo[2] * screenW;
        var r   = geo[3] * screenW;
        var hw  = geo[4] * screenW;
        var box = (2.0 * hw).toNumber();
        if (box < 2) { box = 2; }

        var from = angles[0];
        var to   = angles[1];
        var len;
        if (ccw) { len = to - from; } else { len = from - to; }
        while (len < 0.0) { len += 360.0; }
        var filledLen = progress * len;

        var d2r = Math.PI / 180.0;
        var stepDeg = hw / (r * d2r);                 // ~one half-box per step
        if (stepDeg < 0.5) { stepDeg = 0.5; }
        var steps = (filledLen / stepDeg).toNumber() + 1;

        for (var i = 0; i <= steps; i += 1) {
            var ang = ccw ? (from + filledLen * i / steps) : (from - filledLen * i / steps);
            var rad = ang * d2r;
            var px = (cxp + r * Math.cos(rad)).toNumber();
            var py = (cyp - r * Math.sin(rad)).toNumber();
            dc.setClip(px - hw.toNumber(), py - hw.toNumber(), box, box);
            dc.drawBitmap(ox, oy, bmp);
        }
        dc.clearClip();
    }
}
