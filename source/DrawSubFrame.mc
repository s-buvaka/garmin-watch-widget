import Toybox.Graphics;
import Toybox.Lang;

// Bottom daylight ring (0.0–1.0) around the sub-dial.
// Static outline/track PNG; the gradient fill PNG is revealed 0→progress along the band arc.
class DrawSubFrame {

    static function draw(dc as Graphics.Dc, cx as Number, cy as Number,
                         screenW as Number, dayProgress as Float) as Void {
        Art.drawAt(dc, Art.frameTrack(), screenW, Constants.ART_FR_TRACK_X, Constants.ART_FR_TRACK_Y);
        Art.drawFillArc(dc, screenW, Art.frameFill(),
            [Constants.ART_FR_FILL_X, Constants.ART_FR_FILL_Y, Constants.FRAME_CY_FRAC,
             Constants.FRAME_BAND_MIDR_FRAC, Constants.FRAME_BAND_HW_FRAC],
            [Constants.FR_ANG_0, Constants.FR_ANG_100], false, dayProgress);
    }
}
