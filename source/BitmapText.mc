import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// Crisp text by blitting glyphs from a pre-coloured PNG atlas (packingFormat=png),
// bypassing the CIQ font engine. Glyph metrics live in BitmapTextData.
// Atlases are ASCII-only (32..126).
module BitmapText {
    const LEFT = 0;
    const CENTER = 1;
    const RIGHT = 2;

    var _tan = null;
    var _orange = null;
    var _cream = null;
    var _tried = false;

    function _load() {
        if (_tried) { return; }
        _tried = true;
        try {
            _tan    = WatchUi.loadResource(Rez.Drawables.TextTan);
            _orange = WatchUi.loadResource(Rez.Drawables.TextOrange);
            _cream  = WatchUi.loadResource(Rez.Drawables.NumCream);
        } catch (ex instanceof Lang.Exception) {
        }
    }

    function tan()    { _load(); return _tan; }     // header / date day,month / sub text
    function orange() { _load(); return _orange; }  // date number
    function cream()  { _load(); return _cream; }   // step / HR counts

    // Pixel width of a string in the given metrics table.
    function width(metrics as Array, str as String) as Number {
        var w = 0;
        var b = str.toUtf8Array();
        for (var i = 0; i < b.size(); i += 1) {
            var code = b[i];
            if (code >= 32 && code <= 126) { w += metrics[code - 32][5]; }
        }
        return w;
    }

    // Blit str from atlas. just: LEFT/CENTER/RIGHT. vcenter aligns the cap band on y,
    // otherwise the cap top sits at y.
    function draw(dc as Graphics.Dc, atlas, metrics as Array, cap as Array,
                  x as Numeric, y as Numeric, str as String, just as Number, vcenter as Boolean) as Void {
        if (atlas == null) { return; }
        var total = width(metrics, str);
        var penX = x.toNumber();
        if (just == CENTER) { penX = (x - total / 2).toNumber(); }
        else if (just == RIGHT) { penX = (x - total).toNumber(); }

        var cellTop = vcenter ? (y - (cap[0] + cap[1]) / 2).toNumber() : (y - cap[0]).toNumber();
        var b = str.toUtf8Array();
        for (var i = 0; i < b.size(); i += 1) {
            var code = b[i];
            if (code < 32 || code > 126) { continue; }
            var g = metrics[code - 32];
            var gw = g[2];
            if (gw > 0) {
                var destTop = cellTop + g[4];
                dc.setClip(penX, destTop, gw, g[3]);
                dc.drawBitmap(penX - g[0], destTop - g[1], atlas);
            }
            penX += g[5];
        }
        dc.clearClip();
    }
}
