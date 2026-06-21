import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// Lazily-loaded, cached custom Rajdhani fonts shared by all Draw* components.
// Falls back to the nearest built-in font if a resource fails to load.
module Fonts {
    var _small = null;
    var _smallTried = false;
    var _number = null;
    var _numberTried = false;

    // Small UI text: header, date, labels, gauge labels, sub-dial text.
    function small() {
        if (!_smallTried) {
            _smallTried = true;
            try {
                _small = WatchUi.loadResource(Rez.Fonts.RajdhaniSmall);
            } catch (ex instanceof Lang.Exception) {
                _small = null;
            }
        }
        return (_small != null) ? _small : Graphics.FONT_XTINY;
    }

    // Large numerals: step / heart-rate counts.
    function number() {
        if (!_numberTried) {
            _numberTried = true;
            try {
                _number = WatchUi.loadResource(Rez.Fonts.RajdhaniNumber);
            } catch (ex instanceof Lang.Exception) {
                _number = null;
            }
        }
        return (_number != null) ? _number : Graphics.FONT_NUMBER_MEDIUM;
    }
}
