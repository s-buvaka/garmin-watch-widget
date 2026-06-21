import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;

// Hour, minute, second hands and center cap — exact polygons from
// design-assets/{hour,minute,second}-hand.svg (viewBox 120x480, pivot 60,360).
class DrawHands {

    // SVG polygon points [px,py]; pivot (60,360); viewBox height 480.
    private static const HOUR_BODY  = [[50.5,360.0],[51.5,230.0],[56.5,220.0],[63.5,220.0],[68.5,230.0],[69.5,360.0]];
    private static const HOUR_INLAY = [[55.0,302.0],[55.5,234.0],[58.5,228.0],[61.5,228.0],[64.5,234.0],[65.0,302.0]];
    private static const HAND_TAIL  = [[54.5,356.0],[54.9,306.0],[65.1,306.0],[65.5,356.0]];
    private static const MIN_BODY   = [[50.5,360.0],[51.5,184.0],[56.5,174.0],[63.5,174.0],[68.5,184.0],[69.5,360.0]];
    private static const MIN_INLAY  = [[54.83,302.0],[55.5,188.0],[58.5,182.0],[61.5,182.0],[64.5,188.0],[65.17,302.0]];

    static function draw(dc as Graphics.Dc, cx as Number, cy as Number, screenW as Number,
                         clockTime as System.ClockTime, isAwake as Boolean) as Void {
        var s = screenW.toFloat() / Constants.HAND_VIEWBOX;
        var d2r = Math.PI / 180.0;

        var hourDeg = (clockTime.hour % 12) * 30.0 + clockTime.min * 0.5;
        var minDeg  = clockTime.min * 6.0 + clockTime.sec * 0.1;
        var secDeg  = clockTime.sec * 6.0;

        drawHand(dc, cx, cy, s, hourDeg * d2r, HOUR_BODY, HOUR_INLAY, HAND_TAIL);
        drawHand(dc, cx, cy, s, minDeg * d2r, MIN_BODY, MIN_INLAY, HAND_TAIL);

        // Second hand (active mode only)
        if (isAwake) {
            var a = secDeg * d2r;
            var sinA = Math.sin(a);
            var cosA = Math.cos(a);
            var tip  = 264.0 * s;   // 360-96
            var tail = 34.0 * s;    // 394-360
            var pw = (2.8 * s + 0.5).toNumber();
            if (pw < 1) { pw = 1; }
            dc.setColor(Constants.COLOR_ORANGE_ACCENT, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(pw);
            dc.drawLine(cx - sinA * tail, cy + cosA * tail, cx + sinA * tip, cy - cosA * tip);
            dc.setPenWidth(1);
        }

        // Center cap (always last): black disc + orange ring + orange dot
        var rCap = 9.5 * s;
        var rDot = 4.0 * s;
        dc.setColor(Constants.COLOR_HAND_TAIL, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(cx, cy, rCap);
        dc.setColor(Constants.COLOR_ORANGE_ACCENT, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawCircle(cx, cy, rCap);
        dc.fillCircle(cx, cy, rDot);
        dc.setPenWidth(1);
    }

    // Three-layer hand: white body (+ outline), metallic inlay (+ outline), dark tail.
    private static function drawHand(dc as Graphics.Dc, cx as Number, cy as Number, s as Float,
                                     angleRad as Float, bodyPts as Array, inlayPts as Array,
                                     tailPts as Array) as Void {
        var body = transform(bodyPts, cx, cy, s, angleRad);
        dc.setColor(Constants.COLOR_HAND_BODY, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(body);
        dc.setColor(Constants.COLOR_HAND_OUTLINE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        for (var i = 0; i < body.size(); i += 1) {
            var p = body[i];
            var q = body[(i + 1) % body.size()];
            dc.drawLine(p[0], p[1], q[0], q[1]);
        }
        var inlay = transform(inlayPts, cx, cy, s, angleRad);
        dc.setColor(Constants.COLOR_HAND_INLAY, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(inlay);
        dc.setColor(Constants.COLOR_HAND_INLAY_OUTLINE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        for (var j = 0; j < inlay.size(); j += 1) {
            var a = inlay[j];
            var b = inlay[(j + 1) % inlay.size()];
            dc.drawLine(a[0], a[1], b[0], b[1]);
        }
        dc.setColor(Constants.COLOR_HAND_TAIL, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(transform(tailPts, cx, cy, s, angleRad));
    }

    // Map SVG points to screen: pivot-relative, scale, rotate clockwise by angleRad.
    private static function transform(pts as Array, cx as Number, cy as Number,
                                      s as Float, angleRad as Float) as Array {
        var cosA = Math.cos(angleRad);
        var sinA = Math.sin(angleRad);
        var out = new [pts.size()];
        for (var i = 0; i < pts.size(); i += 1) {
            var rx = (pts[i][0] - 60.0) * s;
            var ry = (pts[i][1] - 360.0) * s;
            out[i] = [cx + (rx * cosA - ry * sinA), cy + (rx * sinA + ry * cosA)];
        }
        return out;
    }
}
