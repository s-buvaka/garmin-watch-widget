import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// Topographic PNG background, centered. Always paints black first so a
// failed/absent bitmap leaves a dark face (never the system default white).
class DrawBackground {

    static function draw(dc as Graphics.Dc, bgBitmap as WatchUi.BitmapResource?) as Void {
        dc.setColor(Constants.COLOR_BLACK, Constants.COLOR_BLACK);
        dc.clear();
        if (bgBitmap != null) {
            var x = (dc.getWidth() - bgBitmap.getWidth()) / 2;
            var y = (dc.getHeight() - bgBitmap.getHeight()) / 2;
            dc.drawBitmap(x, y, bgBitmap);
        }
    }
}
