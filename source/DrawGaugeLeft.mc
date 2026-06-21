import Toybox.Graphics;
import Toybox.Lang;

// Left side gauge — steps progress (0.0–1.0).
// Static track PNG; the gradient fill PNG is revealed 0→progress along the band arc.
class DrawGaugeLeft {

    static function draw(dc as Graphics.Dc, cx as Number, cy as Number,
                         screenW as Number, progress as Float) as Void {
        Art.drawAt(dc, Art.gaugeLeftTrack(), screenW, Constants.ART_GL_TRACK_X, Constants.ART_GL_TRACK_Y);
        Art.drawFillArc(dc, screenW, Art.gaugeLeftFill(),
            [Constants.ART_GL_FILL_X, Constants.ART_GL_FILL_Y, Constants.GAUGE_CY_FRAC,
             Constants.GAUGE_BAND_MIDR_FRAC, Constants.GAUGE_BAND_HW_FRAC],
            [Constants.GL_ANG_0, Constants.GL_ANG_100], false, progress);
    }
}
