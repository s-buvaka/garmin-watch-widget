import Toybox.Graphics;
import Toybox.Lang;

module Constants {
    // --- Base colors ---
    const COLOR_ORANGE  = 0xE87722;
    const COLOR_BLACK   = 0x000000;
    const COLOR_WHITE   = 0xFFFFFF;
    const COLOR_DARK_BG = 0x151515;
    const COLOR_GRAY    = 0x444444;
    const COLOR_DIM     = 0x888888;
    const COLOR_GREEN   = 0x00AA00;
    const COLOR_RED     = 0xCC0000;

    // --- Gauge geometry (fractions of screenW; angles CW from 12 o'clock) ---
    // Derived from design-assets/side-gauges.svg (viewBox 1000, centre 500,500).
    // Pushes both side gauges radially outward (about screen centre) to reduce the
    // gap to the screen edge. 1.0 = exact SVG; >1.0 = closer to the rim.
    const GAUGE_EDGE_SCALE = 1.07f;

    const GAUGE_N_SEGS  = 56;    // progress + fine-scale ticks
    const GAUGE_N_ACCENT = 11;   // accent ticks every 10%
    const GAUGE_BOTTOM_CW_DEG   = 228.0f;  // left bottom / 0%
    const GAUGE_TOP_CW_DEG      = 312.0f;  // left top / 100%
    const GAUGE_R_BOTTOM_CW_DEG = 132.0f;  // right bottom / 0% (mirror)
    const GAUGE_R_TOP_CW_DEG    = 48.0f;   // right top / 100% (mirror)
    // Radial bands (fraction of screenW from centre)
    const GAUGE_PROG_INNER_FRAC   = 0.426f;
    const GAUGE_PROG_OUTER_FRAC   = 0.446f;
    const GAUGE_SCALE_INNER_FRAC  = 0.408f;
    const GAUGE_SCALE_OUTER_FRAC  = 0.420f;
    const GAUGE_ACCENT_INNER_FRAC = 0.386f;
    const GAUGE_ACCENT_OUTER_FRAC = 0.422f;
    const GAUGE_LABEL_R_FRAC      = 0.372f;
    // Pen widths
    const GAUGE_SCALE_PEN  = 1;
    const GAUGE_PROG_PEN   = 3;
    const GAUGE_ACCENT_PEN = 3;

    // --- Gauge colors ---
    const COLOR_GAUGE_FILLED_TOP = 0xf47233;
    const COLOR_GAUGE_FILLED_BOT = 0x6e1a0b;
    const COLOR_GAUGE_EMPTY      = 0x33342e;
    const COLOR_GAUGE_ACCENT     = 0xECE6CE;  // cream accent ticks
    const COLOR_GAUGE_SCALE      = 0xDAD4BA;  // fine scale ticks
    const COLOR_GAUGE_LABEL      = 0x9a9b88;  // 0/50/100 labels

    // --- Icon / element colors ---
    const COLOR_TAN            = 0x8C8E72;
    const COLOR_CREAM          = 0xECE6CE;
    const COLOR_ORANGE_ACCENT  = 0xE8521F;
    const COLOR_DATA_TEXT      = 0xc8c9a8;
    const COLOR_DATA_LABEL     = 0x8a8c6a;
    const COLOR_SUBDIAL_BG     = 0x0d0d0b;
    const COLOR_SUBDIAL_BORDER = 0x3a3c28;

    // --- Sub-dial layout (fractions of screenW) ---
    const SUB_DIAL_CY_OFFSET = 0.21f;    // cy + screenW * this = sub-dial center y
    const SUB_DIAL_RADIUS    = 0.13f;
    const SUB_ICON_SUNSET_FRAC    = 0.085f;  // sunset icon target size / screenW
    const SUB_ICON_ELEVATION_FRAC = 0.085f;  // elevation icon target size / screenW
    const COLOR_ELEV_MASK    = 0x0c0d0e;     // dark mask behind center mountain

    // --- Sub-dial frame (widget-frame.svg, daylight progress ring) ---
    // Frame ring inner radius (viewBox ~415) maps to subR * FRAME_FIT.
    const FRAME_FIT          = 1.38f;
    const FRAME_Y_OFFSET     = 0.05f;       // extra downward shift of the frame (cy + screenW * this)
    const FRAME_PROG_PEN     = 3.6f;        // viewBox stroke width (scaled at runtime)
    const COLOR_FRAME_EMPTY   = 0x2a2b25;   // unfilled segments
    const COLOR_FRAME_OUTLINE = 0x2e2f29;   // thin outline arc

    // --- Data field layout (fractions of screenW) ---
    const STEPS_FIELD_X_OFFSET = 0.30f;  // cx -/+ screenW * this = left/right field center x
    const STEPS_FIELD_Y_OFFSET = 0.02f;  // cy + screenW * this = field cluster top y
    // Top header (brand / divider / date+battery), fractions of screenW above centre
    const MARQ_Y_OFFSET    = 0.300f;  // cy - screenW * this = "MARQ 2" centre
    const DIVIDER_Y_OFFSET = 0.262f;  // cy - screenW * this = thin divider line
    const DATE_Y_OFFSET    = 0.225f;  // cy - screenW * this = date+battery line centre
    const DIVIDER_W_FRAC   = 0.135f;  // divider line width / screenW
    const BATTERY_BOTTOM_Y_OFFSET = 0.41f;  // cy + screenW * this = battery centre (bottom)
    const FIELD_ICON_FRAC      = 0.075f; // steps/heart icon size / screenW
    const BATTERY_ICON_W_FRAC  = 0.10f;  // battery icon width / screenW

    // --- Hand colors (from finalized SVG) ---
    const COLOR_HAND_BODY          = 0xF4F3F3;
    const COLOR_HAND_INLAY         = 0xB5AD8F;
    const COLOR_HAND_INLAY_OUTLINE = 0x7A7460;
    const COLOR_HAND_TAIL          = 0x0E0F11;
    const COLOR_HAND_OUTLINE       = 0xD7D6D1;
    const COLOR_CENTER_DOT   = 0x0E0F11;

    // --- Hand geometry ---
    const HAND_VIEWBOX = 480.0f;   // SVG viewBox height; hand scale = screenW / this

    // --- Text colors (design-assets/typography.md) ---
    const COLOR_DATE         = 0x9a9482;  // date day/month
    const COLOR_FIELD_LABEL  = 0x7a7d6a;  // STEPS / HEART RATE
    const COLOR_NUMBER       = 0xc8c4a8;  // step / HR counts
    const COLOR_UNIT         = 0x8a8878;  // bpm / °C / sub-dial times
    const COLOR_DATEBOX_BG     = 0x12130f;
    const COLOR_DATEBOX_BORDER = 0x2a2c22;

    // --- Hand geometry (legacy fractions, unused by exact-SVG DrawHands) ---
    const HOUR_LEN_FRAC    = 0.35f;
    const HOUR_TAIL_FRAC   = 0.11f;
    const HOUR_BASE_W_FRAC = 0.014f;
    const HOUR_TIP_W_FRAC  = 0.007f;

    const MIN_LEN_FRAC     = 0.44f;
    const MIN_TAIL_FRAC    = 0.11f;
    const MIN_BASE_W_FRAC  = 0.011f;
    const MIN_TIP_W_FRAC   = 0.005f;

    const SEC_TAIL_FRAC    = 0.072f;
    const SEC_TIP_FRAC     = 0.350f;
    const SEC_CIRCLE_FRAC  = 0.020f;
    const SEC_DOT_FRAC     = 0.007f;

    const CAP_DISC_FRAC    = 0.022f;
    const CAP_DOT_FRAC     = 0.010f;
}
