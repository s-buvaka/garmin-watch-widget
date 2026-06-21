import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

// Date box (with inline battery icon), steps field and heart-rate field.
// Icons rendered programmatically from their SVG geometry (icon-battery/steps/heart).
class DrawDataFields {

    // Heart polygon sampled from icon-heart.svg path (viewBox 100, centre ~50,48)
    private static const HEART = [
        [50.0,25.0],[44.0,17.0],[38.0,13.0],[29.0,11.0],[19.0,13.0],[11.0,21.0],
        [9.0,31.0],[12.0,42.0],[22.0,57.0],[36.0,72.0],[50.0,86.0],[64.0,72.0],
        [78.0,57.0],[88.0,42.0],[91.0,31.0],[89.0,21.0],[81.0,13.0],[71.0,11.0],
        [62.0,13.0],[56.0,17.0]
    ];

    static function draw(dc as Graphics.Dc, cx as Number, cy as Number, screenW as Number,
                         dateStr as String, stepsCount as Number, hrBpm as Number,
                         batteryPct as Number) as Void {
        drawHeader(dc, cx, cy, screenW, dateStr);

        // Battery icon — bottom centre of the dial
        var batW = screenW * Constants.BATTERY_ICON_W_FRAC;
        drawBatteryIcon(dc, cx - (batW / 2), cy + (screenW * Constants.BATTERY_BOTTOM_Y_OFFSET),
                        batW, batteryPct);

        var fieldCy = cy + (screenW * Constants.STEPS_FIELD_Y_OFFSET);
        var stepsX = cx - (screenW * Constants.STEPS_FIELD_X_OFFSET);
        var hrX    = cx + (screenW * Constants.STEPS_FIELD_X_OFFSET);
        var icon   = screenW * Constants.FIELD_ICON_FRAC;

        var stepsStr = (stepsCount < 0) ? "--" : stepsCount.toString();
        var hrStr    = (hrBpm < 0) ? "--" : hrBpm.toString();

        drawField(dc, stepsX, fieldCy, icon, stepsStr, false);
        drawField(dc, hrX, fieldCy, icon, hrStr, true);
    }

    // -------- Top header: "MARQ 2" + small date line, raised above centre --------
    private static function drawHeader(dc as Graphics.Dc, cx as Number, cy as Number,
                                       screenW as Number, dateStr as String) as Void {
        var medium = BitmapTextData.TEXT;
        var mcap   = [BitmapTextData.TEXT_CAPTOP, BitmapTextData.TEXT_CAPBOT];
        var tan    = BitmapText.tan();
        var orange = BitmapText.orange();

        // Line 1 — brand
        BitmapText.draw(dc, tan, medium, mcap, cx, cy - (screenW * Constants.MARQ_Y_OFFSET),
                        "MARQ 2", BitmapText.CENTER, true);

        // Thin divider — exactly the width of the "MARQ 2" text
        var divW = BitmapText.width(medium, "MARQ 2");
        var divY = cy - (screenW * Constants.DIVIDER_Y_OFFSET);
        dc.setColor(Constants.COLOR_DATE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawLine(cx - (divW / 2), divY, cx + (divW / 2), divY);

        // Line 2 — date "SAT 20 JUN" (day/month tan, day number orange)
        var day = dateStr;
        var num = "";
        var mon = "";
        var p1 = dateStr.find(" ");
        if (p1 != null) {
            day = dateStr.substring(0, p1);
            var rest = dateStr.substring(p1 + 1, dateStr.length());
            var p2 = rest.find(" ");
            if (p2 != null) {
                num = rest.substring(0, p2);
                mon = rest.substring(p2 + 1, rest.length());
            } else {
                num = rest;
            }
        }

        var sp   = BitmapText.width(medium, " ");
        var wDay = BitmapText.width(medium, day);
        var wNum = BitmapText.width(medium, num);
        var wMon = BitmapText.width(medium, mon);
        var total = wDay + sp + wNum + sp + wMon;
        var dateY = cy - (screenW * Constants.DATE_Y_OFFSET);
        var startX = cx - (total / 2);

        BitmapText.draw(dc, tan, medium, mcap, startX, dateY, day, BitmapText.LEFT, true);
        BitmapText.draw(dc, orange, medium, mcap, startX + wDay + sp, dateY, num, BitmapText.LEFT, true);
        BitmapText.draw(dc, tan, medium, mcap, startX + wDay + sp + wNum + sp, dateY, mon, BitmapText.LEFT, true);
    }

    // icon-battery.svg — viewBox 0 0 130 74.
    private static function drawBatteryIcon(dc as Graphics.Dc, left as Numeric, midY as Numeric,
                                            iconW as Numeric, pct as Number) as Void {
        var s   = iconW / 130.0;
        var top = midY - (74.0 * s / 2.0);
        var pen = (5.0 * s + 0.5).toNumber();
        if (pen < 1) { pen = 1; }

        dc.setColor(Constants.COLOR_TAN, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(pen);
        dc.drawRoundedRectangle(left + 6.0 * s, top + 16.0 * s, 104.0 * s, 42.0 * s, 7.0 * s);
        dc.fillRoundedRectangle(left + 114.0 * s, top + 28.0 * s, 9.0 * s, 18.0 * s, 3.0 * s);

        var clamped = pct;
        if (clamped < 0) { clamped = 0; }
        if (clamped > 100) { clamped = 100; }
        var fillColor = Constants.COLOR_TAN;
        if (pct >= 0 && pct <= 10) {
            fillColor = Constants.COLOR_RED;
        } else if (pct >= 0 && pct <= 20) {
            fillColor = Constants.COLOR_ORANGE_ACCENT;
        }
        if (pct > 0) {
            var maxW = 84.0 * s;
            var barW = maxW * clamped / 100.0;
            dc.setColor(fillColor, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(left + 16.0 * s, top + 26.0 * s, barW, 22.0 * s, 3.0 * s);
        }
        dc.setPenWidth(1);
    }

    // -------- Data field: icon above value, no labels, cluster vertically centred on fcy --------
    private static function drawField(dc as Graphics.Dc, fx as Numeric, fcy as Numeric,
                                      icon as Numeric, value as String, isHeart as Boolean) as Void {
        var valueH  = BitmapTextData.NUM_CAPBOT - BitmapTextData.NUM_CAPTOP;
        var spacing = icon * 0.15;
        var clusterH = icon + spacing + valueH;
        var top = fcy - (clusterH / 2.0);
        var iconCy  = top + (icon / 2.0);
        var valueCy = top + icon + spacing + (valueH / 2.0);

        Icons.drawCentered(dc, isHeart ? Icons.heart() : Icons.steps(), fx, iconCy);
        BitmapText.draw(dc, BitmapText.cream(), BitmapTextData.NUM,
                        [BitmapTextData.NUM_CAPTOP, BitmapTextData.NUM_CAPBOT],
                        fx, valueCy, value, BitmapText.CENTER, true);
    }

    // Pick the built-in font whose height is closest to the target (the icon size),
    // so the step/HR numbers read at roughly icon height across all devices.
    private static const VALUE_FONTS = [
        Graphics.FONT_XTINY, Graphics.FONT_TINY, Graphics.FONT_SMALL, Graphics.FONT_MEDIUM
    ];
    private static function pickFontForHeight(dc as Graphics.Dc, target as Numeric) as Graphics.FontType {
        var best = VALUE_FONTS[0];
        var bestDiff = -1.0;
        for (var i = 0; i < VALUE_FONTS.size(); i += 1) {
            var h = dc.getFontHeight(VALUE_FONTS[i]);
            var diff = (h - target).abs();
            if (bestDiff < 0 || diff < bestDiff) {
                bestDiff = diff;
                best = VALUE_FONTS[i];
            }
        }
        return best;
    }

    // Two footprints (approximation of icon-steps.svg) centred at (ecx, ecy).
    private static function drawStepsIcon(dc as Graphics.Dc, ecx as Numeric, ecy as Numeric, size as Numeric) as Void {
        dc.setColor(Constants.COLOR_TAN, Graphics.COLOR_TRANSPARENT);
        var dx    = size * 0.22;
        var padR  = size * 0.16;
        var heelR = size * 0.10;
        var heelDy = size * 0.26;
        fillEllipse(dc, ecx - dx, ecy - size * 0.06, padR * 0.85, padR, 12);
        dc.fillCircle(ecx - dx - size * 0.02, ecy + heelDy, heelR);
        fillEllipse(dc, ecx + dx, ecy - size * 0.06, padR * 0.85, padR, 12);
        dc.fillCircle(ecx + dx + size * 0.02, ecy + heelDy, heelR);
    }

    // Heart polygon (icon-heart.svg) centred at (ecx, ecy).
    private static function drawHeartIcon(dc as Graphics.Dc, ecx as Numeric, ecy as Numeric, size as Numeric) as Void {
        var s = size / 100.0;
        var poly = new [HEART.size()];
        for (var i = 0; i < HEART.size(); i += 1) {
            poly[i] = [ecx + (HEART[i][0] - 50.0) * s, ecy + (HEART[i][1] - 48.0) * s];
        }
        dc.setColor(Constants.COLOR_TAN, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(poly);
    }

    // Filled ellipse approximation via polygon.
    private static function fillEllipse(dc as Graphics.Dc, ecx as Numeric, ecy as Numeric,
                                        rx as Numeric, ry as Numeric, n as Number) as Void {
        var poly = new [n];
        var twoPi = 2.0 * Math.PI;
        for (var i = 0; i < n; i += 1) {
            var th = twoPi * i.toFloat() / n.toFloat();
            poly[i] = [ecx + rx * Math.cos(th), ecy + ry * Math.sin(th)];
        }
        dc.fillPolygon(poly);
    }
}
