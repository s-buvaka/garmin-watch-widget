import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// Lazily-loaded, cached icon bitmaps (rasterized from the SVGs per device size).
// Shared by the Draw* components; loads once, tolerates missing resources.
module Icons {
    var _heart = null;
    var _steps = null;
    var _sunset = null;
    var _elev = null;
    var _tried = false;

    function _load() {
        if (_tried) { return; }
        _tried = true;
        try {
            _heart  = WatchUi.loadResource(Rez.Drawables.IconHeart);
            _steps  = WatchUi.loadResource(Rez.Drawables.IconSteps);
            _sunset = WatchUi.loadResource(Rez.Drawables.IconSunset);
            _elev   = WatchUi.loadResource(Rez.Drawables.IconElevation);
        } catch (ex instanceof Lang.Exception) {
        }
    }

    function heart()     { _load(); return _heart; }
    function steps()     { _load(); return _steps; }
    function sunset()    { _load(); return _sunset; }
    function elevation() { _load(); return _elev; }

    // Draw a bitmap centred at (cx, cy). No-op if the bitmap failed to load.
    function drawCentered(dc as Graphics.Dc, bmp, cx as Numeric, cy as Numeric) as Void {
        if (bmp == null) { return; }
        dc.drawBitmap(cx - bmp.getWidth() / 2, cy - bmp.getHeight() / 2, bmp);
    }
}
