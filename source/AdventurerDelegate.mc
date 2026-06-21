import Toybox.WatchUi;
import Toybox.Lang;

class AdventurerDelegate extends WatchUi.WatchFaceDelegate {

    function initialize() {
        WatchFaceDelegate.initialize();
    }

    function onPowerBudgetExceeded(powerInfo as WatchUi.WatchFacePowerInfo) as Void {
        // required override — no action needed
    }
}
