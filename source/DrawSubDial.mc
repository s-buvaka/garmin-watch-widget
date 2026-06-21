import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

// Bottom sub-dial: sunrise/sunset icon + times, divider, elevation icon + temperature.
// Icons are rendered programmatically from their SVG path geometry.
class DrawSubDial {

    static function draw(dc as Graphics.Dc, cx as Number, cy as Number, screenW as Number,
                         sunriseStr as String, sunsetStr as String, tempStr as String) as Void {
        var subCy = cy + (screenW * Constants.SUB_DIAL_CY_OFFSET);
        var subR  = screenW * Constants.SUB_DIAL_RADIUS;

        // (No disc/border — the weather widgets sit directly on the dial)

        // 3. Sunset icon
        Icons.drawCentered(dc, Icons.sunset(), cx, subCy - (subR * 0.38));

        // 4. Sunrise · sunset times
        dc.setColor(Constants.COLOR_UNIT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, subCy - (subR * 0.10), Fonts.small(),
                    sunriseStr + " · " + sunsetStr,
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // 5. Divider
        dc.setColor(Constants.COLOR_SUBDIAL_BORDER, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawLine(cx - (subR * 0.75), subCy, cx + (subR * 0.75), subCy);

        // 6. Elevation icon
        Icons.drawCentered(dc, Icons.elevation(), cx, subCy + (subR * 0.22));

        // 7. Temperature
        dc.setColor(Constants.COLOR_UNIT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, subCy + (subR * 0.62), Fonts.small(), tempStr,
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // icon-sunset.svg — viewBox 0 0 120 100. icx/icy = icon center on screen, size = target width.
    private static function drawSunsetIcon(dc as Graphics.Dc, icx as Numeric, icy as Numeric, size as Numeric) as Void {
        var s   = size / 120.0;
        var vcx = 60.0;
        var vcy = 50.0;
        var col = Constants.COLOR_ORANGE_ACCENT;
        var pen = (6.0 * s).toNumber();
        if (pen < 1) { pen = 1; }

        // Sun dome — upper semicircle, center (60,62) r26, as a filled polygon
        var n   = 11;
        var dome = new [n];
        for (var i = 0; i < n; i += 1) {
            var th = Math.PI - (Math.PI * i.toFloat() / (n - 1).toFloat());  // π → 0
            var vx = 60.0 + 26.0 * Math.cos(th);
            var vy = 62.0 - 26.0 * Math.sin(th);
            dome[i] = [icx + (vx - vcx) * s, icy + (vy - vcy) * s];
        }
        dc.setColor(col, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(dome);

        // Rays + horizon lines (viewBox endpoints)
        var lines = [
            [60.0, 30.0, 60.0, 16.0],
            [36.0, 40.0, 27.0, 31.0],
            [84.0, 40.0, 93.0, 31.0],
            [22.0, 62.0,  8.0, 62.0],
            [98.0, 62.0, 112.0, 62.0],
            [10.0, 76.0, 110.0, 76.0],
            [32.0, 88.0,  88.0, 88.0]
        ];
        dc.setPenWidth(pen);
        for (var j = 0; j < lines.size(); j += 1) {
            var l = lines[j];
            dc.drawLine(icx + (l[0] - vcx) * s, icy + (l[1] - vcy) * s,
                        icx + (l[2] - vcx) * s, icy + (l[3] - vcy) * s);
        }
        dc.setPenWidth(1);
    }

    // icon-elevation.svg — viewBox 0 0 120 82.
    private static function drawElevationIcon(dc as Graphics.Dc, icx as Numeric, icy as Numeric, size as Numeric) as Void {
        var s   = size / 120.0;
        var vcx = 60.0;
        var vcy = 41.0;
        var tan = Constants.COLOR_TAN;
        var pen = (5.0 * s).toNumber();
        if (pen < 1) { pen = 1; }
        dc.setPenWidth(pen);

        // Two background mountains (polylines)
        var bg = [
            [6.0, 72.0, 32.0, 36.0, 58.0, 72.0],
            [62.0, 72.0, 90.0, 26.0, 114.0, 72.0]
        ];
        dc.setColor(tan, Graphics.COLOR_TRANSPARENT);
        for (var b = 0; b < bg.size(); b += 1) {
            var m = bg[b];
            dc.drawLine(icx + (m[0] - vcx) * s, icy + (m[1] - vcy) * s,
                        icx + (m[2] - vcx) * s, icy + (m[3] - vcy) * s);
            dc.drawLine(icx + (m[2] - vcx) * s, icy + (m[3] - vcy) * s,
                        icx + (m[4] - vcx) * s, icy + (m[5] - vcy) * s);
        }

        // Center mountain mask (dark fill) then outline
        var mask = [
            [icx + (20.0 - vcx) * s, icy + (74.0 - vcy) * s],
            [icx + (60.0 - vcx) * s, icy + (12.0 - vcy) * s],
            [icx + (100.0 - vcx) * s, icy + (74.0 - vcy) * s]
        ];
        dc.setColor(Constants.COLOR_ELEV_MASK, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(mask);

        dc.setColor(tan, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(icx + (20.0 - vcx) * s, icy + (72.0 - vcy) * s,
                    icx + (60.0 - vcx) * s, icy + (14.0 - vcy) * s);
        dc.drawLine(icx + (60.0 - vcx) * s, icy + (14.0 - vcy) * s,
                    icx + (100.0 - vcx) * s, icy + (72.0 - vcy) * s);

        // Base line
        dc.drawLine(icx + (6.0 - vcx) * s, icy + (72.0 - vcy) * s,
                    icx + (114.0 - vcx) * s, icy + (72.0 - vcy) * s);
        dc.setPenWidth(1);
    }
}
