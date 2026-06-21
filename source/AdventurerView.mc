import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

// Thin coordinator: fetches all data once, then calls each Draw* component in
// order. No drawing logic of its own.
class AdventurerView extends WatchUi.WatchFace {

    private var _isAwake as Boolean = true;
    private var _bgBitmap as WatchUi.BitmapResource?;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Graphics.Dc) as Void {
        // Load background bitmap once. loadResource can throw, so guard it.
        _bgBitmap = null;
        try {
            var bgId = AdventurerLogic.getBackgroundId();
            _bgBitmap = WatchUi.loadResource(bgId) as WatchUi.BitmapResource;
        } catch (ex instanceof Lang.Exception) {
            _bgBitmap = null;
        }
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        // Smooth edges for all code-drawn shapes (hands, gauges, frame) where supported.
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }

        var screenW = dc.getWidth();
        var screenH = dc.getHeight();
        var cx = screenW / 2;
        var cy = screenH / 2;

        // --- Fetch all data once ---
        var stepsCount = AdventurerLogic.getStepCount();
        var stepsProgress = AdventurerLogic.getStepsProgress();

        var hrBpm = AdventurerLogic.getHeartRateBpm();
        var hrProgress = AdventurerLogic.getHrProgress();

        var dateStr  = AdventurerLogic.getDateString();
        var tempStr  = AdventurerLogic.getTemperature();
        var sun      = AdventurerLogic.getSunriseSunset();
        var batteryPct = AdventurerLogic.getBatteryPercent();
        var dayProgress = AdventurerLogic.getDaylightProgress();
        var clockTime  = System.getClockTime();

        // --- Draw in order ---
        DrawBackground.draw(dc, _bgBitmap);
        DrawGaugeLeft.draw(dc, cx, cy, screenW, stepsProgress);
        DrawGaugeRight.draw(dc, cx, cy, screenW, hrProgress);
        DrawSubFrame.draw(dc, cx, cy, screenW, dayProgress);
        DrawSubDial.draw(dc, cx, cy, screenW, sun[0], sun[1], tempStr);
        DrawDataFields.draw(dc, cx, cy, screenW, dateStr, stepsCount, hrBpm, batteryPct);
        DrawHands.draw(dc, cx, cy, screenW, clockTime, _isAwake);
    }

    function onEnterSleep() as Void {
        _isAwake = false;
        WatchUi.requestUpdate();
    }

    function onExitSleep() as Void {
        _isAwake = true;
        WatchUi.requestUpdate();
    }
}
