import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class AdventurerApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        var view = new AdventurerView();
        var delegate = new AdventurerDelegate();
        return [view, delegate];
    }
}

function getApp() as AdventurerApp {
    return Application.getApp() as AdventurerApp;
}
