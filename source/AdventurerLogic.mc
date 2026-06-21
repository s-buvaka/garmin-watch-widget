import Toybox.ActivityMonitor;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Position;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.UserProfile;
import Toybox.Weather;

class AdventurerLogic {

    // Returns current step count, -1 if unavailable
    (:release)
    static function getStepCount() as Number {
        var info = ActivityMonitor.getInfo();
        if (info == null || info.steps == null) { return -1; }
        return info.steps;
    }

    // Mock — debug/simulator builds only (stripped from release)
    (:debug)
    static function getStepCount() as Number {
        return 6542;
    }

    // Returns daily step goal, -1 if unavailable
    (:release)
    static function getStepGoal() as Number {
        var info = ActivityMonitor.getInfo();
        if (info == null || info.stepGoal == null) { return -1; }
        return info.stepGoal;
    }

    // Mock — debug/simulator builds only
    (:debug)
    static function getStepGoal() as Number {
        return 10000;
    }

    // Returns current HR in bpm, -1 if unavailable
    static function getHeartRateBpm() as Number {
        var hrHistory = ActivityMonitor.getHeartRateHistory(1, true);
        if (hrHistory == null) { return -1; }
        var sample = hrHistory.next();
        if (sample == null || sample.heartRate == null ||
            sample.heartRate == ActivityMonitor.INVALID_HR_SAMPLE) {
            return -1;
        }
        return sample.heartRate;
    }

    // Returns max HR from user profile. Falls back to 190 if unavailable.
    static function getMaxHeartRate() as Number {
        try {
            var zones = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_GENERIC);
            if (zones != null && zones.size() > 0) {
                // zones holds the boundary bpm values; the last entry is the top of the highest zone.
                var lastZone = zones[zones.size() - 1];
                if (lastZone != null && lastZone > 100) { return lastZone; }
            }
        } catch (ex instanceof Lang.Exception) {}
        return 190; // safe default
    }

    // Returns temperature as String "+N°", "--" if unavailable
    static function getTemperature() as String {
        var conditions = null;
        try {
            conditions = Weather.getCurrentConditions();
        } catch (ex instanceof Lang.Exception) {
            return "--";
        }
        if (conditions == null || conditions.temperature == null) { return "--"; }
        var temp = conditions.temperature.toNumber();
        var prefix = temp >= 0 ? "+" : "";
        return prefix + temp.toString() + "°";
    }

    // Returns battery as Integer 0-100, -1 if unavailable
    static function getBatteryPercent() as Number {
        var stats = System.getSystemStats();
        if (stats == null || stats.battery == null) { return -1; }
        return stats.battery.toNumber();
    }

    // Returns date as String "SAT 20 JUN"
    static function getDateString() as String {
        var now = Time.now();
        var info = Gregorian.info(now, Time.FORMAT_SHORT);
        if (info == null) { return "--"; }
        var days   = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
        var months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
                      "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
        var day   = (info.day_of_week != null && info.day_of_week >= 1 && info.day_of_week <= 7)
                    ? days[info.day_of_week - 1] : "--";
        var month = (info.month != null && info.month > 0 && info.month <= 12)
                    ? months[info.month - 1] : "--";
        var date  = info.day != null ? info.day.toString() : "--";
        return day + " " + date + " " + month;
    }

    // Returns [sunriseStr, sunsetStr] e.g. ["5:12", "21:08"], ["--","--"] if unavailable.
    // Uses Weather.getSunrise/getSunset (API 3.3.0), which need a position fix.
    static function getSunriseSunset() as Array {
        var posInfo = Position.getInfo();
        if (posInfo == null || posInfo.position == null) { return ["--", "--"] as Array; }
        var loc = posInfo.position;
        var now = Time.now();

        var rise = null;
        var set  = null;
        try {
            rise = Weather.getSunrise(loc, now);
            set  = Weather.getSunset(loc, now);
        } catch (ex instanceof Lang.Exception) {
            return ["--", "--"] as Array;
        }
        return [formatTime(rise), formatTime(set)] as Array;
    }

    // Mock — debug/simulator builds only. Cycles the daylight progress 0.0 -> 1.0
    // once per minute (driven by the seconds hand) so the ring animates and the
    // fill is clearly visible in the simulator.
    (:debug)
    static function getDaylightProgress() as Float {
        var t = System.getClockTime();
        return (t.sec % 60) / 60.0;
    }

    // Fraction of daylight elapsed: 0.0 at/before sunrise and at/after sunset (night),
    // rising to 1.0 just before sunset. Returns 0.0 if unavailable.
    (:release)
    static function getDaylightProgress() as Float {
        var posInfo = Position.getInfo();
        if (posInfo == null || posInfo.position == null) { return 0.0; }
        var loc = posInfo.position;
        var now = Time.now();

        var rise = null;
        var set  = null;
        try {
            rise = Weather.getSunrise(loc, now);
            set  = Weather.getSunset(loc, now);
        } catch (ex instanceof Lang.Exception) {
            return 0.0;
        }
        if (rise == null || set == null) { return 0.0; }

        var nowS  = now.value();
        var riseS = rise.value();
        var setS  = set.value();
        if (setS <= riseS) { return 0.0; }
        if (nowS <= riseS || nowS >= setS) { return 0.0; }  // night
        return (nowS - riseS).toFloat() / (setS - riseS).toFloat();
    }

    // Formats a Time.Moment as "H:MM", returns "--" if null
    private static function formatTime(moment as Time.Moment?) as String {
        if (moment == null) { return "--"; }
        var info = Gregorian.info(moment, Time.FORMAT_SHORT);
        if (info == null) { return "--"; }
        var h = info.hour != null ? info.hour.toString() : "--";
        var m = info.min  != null ? info.min.format("%02d") : "--";
        return h + ":" + m;
    }

    // Picks the background bitmap resource id based on screen width
    static function getBackgroundId() as Lang.ResourceId {
        var w = System.getDeviceSettings().screenWidth;
        if (w <= 240) { return Rez.Drawables.background_240; }
        if (w <= 280) { return Rez.Drawables.background_280; }
        return Rez.Drawables.background_390;
    }
}
