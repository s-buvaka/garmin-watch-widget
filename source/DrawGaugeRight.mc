import Toybox.Graphics;
import Toybox.Lang;

// Right side gauge — heart-rate progress (0.0–1.0).
// Static track PNG; the gradient fill PNG is revealed 0→progress along the band arc.
class DrawGaugeRight {

    static function draw(dc as Graphics.Dc, cx as Number, cy as Number,
                         screenW as Number, progress as Float) as Void {
        Art.drawAt(dc, Art.gaugeRightTrack(), screenW, Constants.ART_GR_TRACK_X, Constants.ART_GR_TRACK_Y);
        Art.drawFillArc(dc, screenW, Art.gaugeRightFill(),
            [Constants.ART_GR_FILL_X, Constants.ART_GR_FILL_Y, Constants.GAUGE_CY_FRAC,
             Constants.GAUGE_BAND_MIDR_FRAC, Constants.GAUGE_BAND_HW_FRAC],
            [Constants.GR_ANG_0, Constants.GR_ANG_100], true, progress);
    }
}
