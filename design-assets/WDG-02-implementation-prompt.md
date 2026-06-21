# WDG-02 — Adventurer Watchface: Full Implementation Prompt

## Before you write a single line of code

Read all of the following files in full. Your implementation must be derived exactly from their content — no approximations, no substitutions.

```
design-assets/side-gauges.svg
design-assets/hour-hand.svg
design-assets/minute-hand.svg
design-assets/second-hand.svg
design-assets/icon-steps.svg
design-assets/icon-sunset.svg
design-assets/icon-heart.svg
design-assets/icon-elevation.svg
design-assets/icon-battery.svg
design-assets/typography.md
design-assets/watchface-bg.png   (bitmap — note filename for resource ID)
design-assets/topo-bg.png        (bitmap — note filename for resource ID)
```

Also read the full CLAUDE.md before touching any file.

---

## Platform

- Garmin Connect IQ, Monkey C, `minApiLevel 3.3.0`
- App type: `watch-face` (extends `WatchUi.WatchFace`)
- Target devices: fenix6 (240px), fenix6s (232px), fenix6xpro (280px), fr245 (240px), fr945 (240px), marq2 (280px)

---

## Architecture

Every drawing responsibility lives in its own file. `AdventurerView.mc` is a thin coordinator — no drawing logic of its own.

```
source/
  AdventurerApp.mc        — unchanged
  AdventurerDelegate.mc   — unchanged
  AdventurerLogic.mc      — data layer; add new methods listed below
  AdventurerView.mc       — calls draw methods in order; fetches all data once per onUpdate
  Constants.mc            — all colors and fractions; extend as needed

  DrawBackground.mc       — renders topo bitmap
  DrawGaugeLeft.mc        — left arc: steps progress
  DrawGaugeRight.mc       — right arc: heart rate progress
  DrawSubDial.mc          — bottom sub-dial: sunset icon + times + divider + elevation icon + temp
  DrawDataFields.mc       — date box with battery, steps count + icon, HR count + icon
  DrawHands.mc            — hour, minute, second hands + center cap
```

Public interface of each Draw* file: one static `draw(dc, ...)` method. No shared helpers between Draw files.

---

## Drawing order in AdventurerView.onUpdate

```monkeyc
var clockTime   = System.getClockTime();
var stepsCount  = AdventurerLogic.getStepCount();
var stepsGoal   = AdventurerLogic.getStepGoal();
var hrBpm       = AdventurerLogic.getHeartRateBpm();
var hrMax       = AdventurerLogic.getMaxHeartRate();
var dateStr     = AdventurerLogic.getDateString();
var temp        = AdventurerLogic.getTemperature();
var sunTimes    = AdventurerLogic.getSunriseSunset();
var batteryPct  = AdventurerLogic.getBatteryPercent();

var cx = dc.getWidth() / 2;
var cy = dc.getHeight() / 2;
var screenW = dc.getWidth();

var stepsProgress = (stepsCount > 0 && stepsGoal > 0)
    ? (stepsCount.toFloat() / stepsGoal.toFloat()).min(1.0f)
    : 0.0f;
var hrProgress = (hrBpm > 0 && hrMax > 0)
    ? (hrBpm.toFloat() / hrMax.toFloat()).min(1.0f)
    : 0.0f;

DrawBackground.draw(dc, _bgBitmap);
DrawGaugeLeft.draw(dc, cx, cy, screenW, stepsProgress);
DrawGaugeRight.draw(dc, cx, cy, screenW, hrProgress);
DrawSubDial.draw(dc, cx, cy, screenW, sunTimes[0], sunTimes[1], temp);
DrawDataFields.draw(dc, cx, cy, screenW, dateStr, stepsCount, hrBpm, batteryPct);
DrawHands.draw(dc, cx, cy, screenW, clockTime, _isAwake);
```

---

## Background bitmaps

Copy `design-assets/watchface-bg.png` and `design-assets/topo-bg.png` into `resources/images/`.

In `resources/drawables.xml`, declare them:
```xml
<bitmap id="WatchfaceBg" filename="watchface-bg.png"/>
<bitmap id="TopoBg"      filename="topo-bg.png"/>
```

`AdventurerLogic.getBackgroundId()` already selects the correct resource ID based on `screenWidth`. Verify that it maps to these new IDs — update if needed.

`DrawBackground.draw(dc, bitmap)`: center the bitmap at `(cx, cy)` with `dc.drawBitmap`.

---

## Left Gauge — DrawGaugeLeft.mc

### Source file
`design-assets/side-gauges.svg` — read groups `left-scale` and `left-progress`.

### Coordinate system
The SVG has `viewBox="0 0 1000 1000"` with center at (500, 500).

Scale and offset every coordinate to screen space:
```monkeyc
var s  = screenW.toFloat() / 1000.0f;
var ox = cx - 500.0f * s;
var oy = cy - 500.0f * s;
// screen x = svg_x * s + ox
// screen y = svg_y * s + oy
```

### left-scale (static, always drawn)

From the SVG, the `left-scale` group contains:
- 101 short tan tick lines, stroke `#DAD4BA`, stroke-width 2.6
- 11 accent lines: 3 orange `#E8521F` stroke-width 5 (at top, center, bottom), and 8 cream `#ECE6CE` stroke-width 4.6

Extract every `<line>` from the `left-scale` group. Hardcode the x1, y1, x2, y2 values as a Monkey C `Array` of `[x1, y1, x2, y2, colorHex, widthFixed10]` (multiply float coords by 100 and store as integers to avoid floats in arrays, or use Float arrays — your choice).

Draw each line:
```monkeyc
dc.setPenWidth(scaledWidth);
dc.setColor(color, Graphics.COLOR_TRANSPARENT);
dc.drawLine(x1*s+ox, y1*s+oy, x2*s+ox, y2*s+oy);
```

Draw `left-scale` first (background ticks), then `left-progress` on top.

### left-progress (dynamic, driven by stepsProgress)

From the SVG, the `left-progress` group contains exactly 56 `<line>` elements.
- Lines 1–26: orange-to-dark-red gradient (#f47233 → #6e1a0b), stroke-width 3
- Lines 27–56: dark #33342e, stroke-width 3

Line 1 is at the bottom of the arc (0%), line 56 is at the top (100%).

For a given `stepsProgress` (0.0–1.0):
- `filledCount = Math.round(stepsProgress * 56).toNumber()`
- Lines 1..filledCount: draw using the color stored in the SVG (read it verbatim from the SVG — each line already has the correct gradient color)
- Lines filledCount+1..56: draw as `#33342e`

Hardcode all 56 line coordinate pairs and their original SVG gradient colors as arrays. Draw them using the rule above.

---

## Right Gauge — DrawGaugeRight.mc

Identical logic to `DrawGaugeLeft.mc`, but use groups `right-scale` and `right-progress` from the same SVG.

The `right-progress` group also has 56 lines:
- Lines 1–41: orange-to-dark-red gradient (#f47233 → #6e1a0b)
- Lines 42–56: #33342e

Progress is `hrProgress`.

---

## AdventurerLogic.mc — new methods

```monkeyc
import Toybox.UserProfile;

// Returns current step count, or -1 if unavailable
static function getStepCount() as Number {
    var info = ActivityMonitor.getInfo();
    if (info == null || info.steps == null) { return -1; }
    return info.steps;
}

// Returns daily step goal, or -1 if unavailable
static function getStepGoal() as Number {
    var info = ActivityMonitor.getInfo();
    if (info == null || info.stepGoal == null) { return -1; }
    return info.stepGoal;
}

// Returns current HR in bpm, or -1 if unavailable
static function getHeartRateBpm() as Number {
    var iter = ActivityMonitor.getHeartRateHistory(1, true);
    if (iter == null) { return -1; }
    var sample = iter.next();
    if (sample == null || sample.heartRate == null ||
        sample.heartRate == ActivityMonitor.INVALID_HR_SAMPLE) { return -1; }
    return sample.heartRate;
}

// Returns max HR from user profile. Falls back to 190.
static function getMaxHeartRate() as Number {
    try {
        var zones = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_GENERIC);
        if (zones != null && zones.size() > 0) {
            var last = zones[zones.size() - 1];
            if (last != null && last > 100) { return last; }
        }
    } catch (ex instanceof Lang.Exception) {}
    return 190;
}
```

Remove the old `getSteps()` and `getHeartRate()` methods if they returned Strings — replace callers.

---

## Hands — DrawHands.mc

### Source files
`design-assets/hour-hand.svg`, `design-assets/minute-hand.svg`, `design-assets/second-hand.svg`

All three SVGs use `viewBox="0 0 120 480"` with **pivot point at (60, 360)**.

### Coordinate transform
To draw a hand at angle `angleDeg` (0° = 12 o'clock, clockwise):

```monkeyc
var angleRad = (angleDeg - 90.0f) * Math.PI / 180.0f;
// For each point (px, py) from the SVG path:
// Translate to pivot-relative:
var rx = px - 60.0f;
var ry = py - 360.0f;
// Scale:
var s = screenW.toFloat() / 240.0f;  // normalize to 240px reference
rx *= s;
ry *= s;
// Rotate:
var rx2 = rx * Math.cos(angleRad) - ry * Math.sin(angleRad);
var ry2 = rx * Math.sin(angleRad) + ry * Math.cos(angleRad);
// Translate to screen center:
var sx = cx + rx2.toNumber();
var sy = cy + ry2.toNumber();
```

Build screen-space polygon arrays from all transformed points, then call `dc.fillPolygon`.

### Hour hand (hour-hand.svg)

Three polygon layers drawn in this order:

**Layer 1 — main body** (fill `#F4F3F3`, stroke `#D7D6D1` width 1):
Points from SVG: `(50.5,360) (51.5,230) (56.5,220) (63.5,220) (68.5,230) (69.5,360)`

**Layer 2 — metallic inlay** (fill `#B5AD8F`, no stroke):
Points: `(55.0,302) (55.5,234) (58.5,228) (61.5,228) (64.5,234) (65.0,302)`

**Layer 3 — tail block** (fill `#0E0F11`, no stroke):
Points: `(54.5,356) (54.9,306) (65.1,306) (65.5,356)`

### Minute hand (minute-hand.svg)

Same three-layer structure:

**Layer 1** (fill `#F4F3F3`, stroke `#D7D6D1` width 1):
Points: `(50.5,360) (51.5,184) (56.5,174) (63.5,174) (68.5,184) (69.5,360)`

**Layer 2** (fill `#B5AD8F`):
Points: `(54.83,302) (55.5,188) (58.5,182) (61.5,182) (64.5,188) (65.17,302)`

**Layer 3** (fill `#0E0F11`):
Points: `(54.5,356) (54.9,306) (65.1,306) (65.5,356)`

### Second hand (second-hand.svg) — active mode only (`_isAwake == true`)

From the SVG (pivot at 60, 360):

- **Tip rect**: x=58.6, y=96, width=2.8, height=252 → extends from y=96 to y=348 above pivot
  → pivot-relative: x_center=60, tip_end at (60, 96), tail_end at (60, 348)
  → Draw as `dc.drawLine` from tip to tail with penWidth scaled: `Math.max(1, (2.8f * s).toNumber())`
  
- **Tail rect**: x=58.2, y=360, width=3.6, height=34 → y=360 to y=394 below pivot
  → Draw separately or combine into one line from y=96 to y=394

- Actually simpler: draw as a single `dc.drawLine` from tip to tail through pivot, all color `#E8521F`, penWidth 2.

- **Pivot circle** (unfilled ring): `dc.drawCircle(cx, cy, (9.5f * s).toNumber())`, color `#E8521F`, penWidth scaled from stroke-width 3.4

- **Center dot** (filled): `dc.fillCircle(cx, cy, (3.2f * s).toNumber())`, color `#0E0F11`

Tip pixel distance from pivot: `360 - 96 = 264` SVG units → scaled: `264 * s`
Tail pixel distance from pivot: `394 - 360 = 34` SVG units → scaled: `34 * s`

```monkeyc
var tipDist  = (264.0f * s).toNumber();
var tailDist = (34.0f * s).toNumber();
dc.setColor(0xE8521F, Graphics.COLOR_TRANSPARENT);
dc.setPenWidth(Math.max(1, (2.8f * s).toNumber()));
dc.drawLine(
    cx + (-Math.sin(angleRad) * tailDist).toNumber(),
    cy + ( Math.cos(angleRad) * tailDist).toNumber(),
    cx + ( Math.sin(angleRad) * tipDist).toNumber(),
    cy + (-Math.cos(angleRad) * tipDist).toNumber()
);
```

### Center cap (always drawn last, over all hands)

- Orange ring: `dc.drawCircle(cx, cy, (9.5f*s).toNumber())`, color `#E8521F`, penWidth 2
- Black fill: `dc.fillCircle(cx, cy, (9.5f*s).toNumber())`, color `#0E0F11`
- Orange dot: `dc.fillCircle(cx, cy, (4.0f*s).toNumber())`, color `#E8521F`

---

## Angle calculations

```monkeyc
var hourAngle   = (clockTime.hour % 12) * 30.0f + clockTime.min * 0.5f;
var minuteAngle = clockTime.min * 6.0f + clockTime.sec * 0.1f;
var secondAngle = clockTime.sec * 6.0f;
```

0° = 12 o'clock, positive = clockwise.

---

## Icons — DrawDataFields.mc and DrawSubDial.mc

All icons are rendered programmatically using `dc.fillPolygon` and `dc.drawLine`. Connect IQ does not support SVG at runtime — read the SVG path/rect geometry and convert to point arrays.

### How to convert SVG paths to Monkey C polygons

For each SVG `<path>` or `<rect>` or `<line>` in the icon files:
1. Extract the coordinate values
2. Compute scale factor: `s = targetSizePx / svgViewBoxWidth`
3. Offset to the icon's screen position `(ix, iy)` (top-left of icon bounding box)
4. Each point: `[Math.round(px * s + ix), Math.round(py * s + iy)]`
5. Pass as `[[x,y],[x,y],...]` to `dc.fillPolygon`

For curves/arcs in paths: approximate with 6–12 polygon points along the curve.

### icon-steps.svg (viewBox 200×200, fill #8C8E72)

Two footprint shapes. Each is a `<path>` with a `<use>` transform for the second. Target size: `screenW * 0.075` px. Position: left data field, above "STEPS" label.

### icon-heart.svg (viewBox 100×100, fill #8C8E72)

Single heart `<path>`. Approximate the bezier curve with ~14 polygon points. Target size: `screenW * 0.075` px. Position: right data field, above "HEART RATE" label.

### icon-battery.svg (viewBox 130×74, stroke/fill #8C8E72)

Three elements:
1. Outer rect (stroke only, rx=7): `dc.drawRoundedRectangle`
2. Terminal nub (fill, rx=3): `dc.fillRoundedRectangle`
3. Fill bar (fill, rx=3): `dc.fillRoundedRectangle` — show full width when battery > 20%, orange `#E8521F` when ≤ 20%, red `#CC0000` when ≤ 10%

Target width: `screenW * 0.10` px. Position: right side inside date box.

### icon-sunset.svg (viewBox 120×100, fill/stroke #E8521F)

Elements (all color `#E8521F`):
1. Sun body: polygon approximating the `M34 62 L50 62 L60 52 L70 62 L86 62 A26 26 0 0 0 34 62 Z` path (half-circle + notch — approximate arc with ~8 points)
2. Top ray (vertical line): `dc.drawLine`
3. Two diagonal rays: `dc.drawLine` each
4. Two horizontal side rays: `dc.drawLine` each
5. Two horizon lines (different lengths): `dc.drawLine` each

Target width: `screenW * 0.085` px. Position: sub-dial, upper half, centered.

### icon-elevation.svg (viewBox 120×82, stroke #8C8E72)

Elements:
1. Left background mountain: `dc.drawLine` x2 (path `M6 72 L32 36 L58 72`)
2. Right background mountain: `dc.drawLine` x2 (path `M62 72 L90 26 L114 72`)
3. Mask rectangle covering background mountains (fill `#0c0d0e`): `dc.fillPolygon`
4. Center mountain outline: `dc.drawLine` x2 (path `M20 72 L60 14 L100 72`)
5. Base line: `dc.drawLine` (x=6 to x=114, y=72)

All strokes: color `#8C8E72`, penWidth scaled from stroke-width 5.

Target width: `screenW * 0.085` px. Position: sub-dial, lower half, centered.

---

## Typography

`design-assets/typography.md` defines font weights and sizes. Connect IQ does not support custom fonts (Rajdhani). Map to the closest system fonts:

| Element              | Connect IQ font    | Color     |
|----------------------|--------------------|-----------|
| Date day/month text  | FONT_SMALL         | #9a9482   |
| Date number          | FONT_SMALL bold    | #E8521F   |
| STEPS / HEART RATE   | FONT_XTINY         | #7a7d6a   |
| Step count           | FONT_LARGE or FONT_NUMBER_MEDIUM | #c8c4a8 |
| HR number            | FONT_LARGE or FONT_NUMBER_MEDIUM | #c8c4a8 |
| bpm / °C             | FONT_TINY          | #8a8878   |
| Gauge labels 0/50/100| FONT_XTINY         | #8d8f81   |
| Sub-dial times       | FONT_XTINY         | #8a8878   |

Gauge scale labels ("0", "50", "100") must be drawn. Their SVG positions are in the `labels` group of `side-gauges.svg` — scale and offset using the same `s`/`ox`/`oy` formula.

---

## Sub-dial — DrawSubDial.mc

Circle centered at `(cx, cy + screenW * 0.21)`, radius `screenW * 0.13`.

Draw order:
1. Fill: `dc.fillCircle`, color `#0d0d0b`
2. Stroke: `dc.drawCircle`, color `#3a3c28`, penWidth 1
3. Sunset icon (upper half, centered)
4. Sunrise time + `·` + sunset time, FONT_XTINY, color `#8a8878`, centered below icon
5. Horizontal divider: `dc.drawLine`, color `#3a3c28`
6. Elevation icon (lower half, centered)
7. Temperature string (e.g. `+18°`), FONT_XTINY, color `#8a8878`, below elevation icon

---

## Date box — DrawDataFields.mc

Box:
- Position: `(cx - screenW*0.185, cy - screenW*0.215)`, width `screenW*0.37`, height `screenW*0.067`
- Fill: `#12130f`
- Stroke: `#2a2c22`, penWidth 1

Content: `DAY DD MON` where:
- "SAT" and "JUN" → color `#9a9482`, FONT_SMALL
- "20" (day number) → color `#E8521F`, FONT_SMALL
- Battery icon flush right inside box

---

## manifest.xml

Ensure these permissions exist (do NOT add others):
```xml
<iq:uses-permission id="ActivityMonitor"/>
<iq:uses-permission id="UserProfiles"/>
<iq:uses-permission id="Positioning"/>
<iq:uses-permission id="Weather"/>
```

---

## Null safety rules

Every system API call must be guarded. Examples:
- `ActivityMonitor.getInfo()` → check `!= null` before accessing `.steps`
- `UserProfile.getHeartRateZones()` → wrap in `try/catch`
- `Weather.getSunrise()` → check `!= null`
- All `dc.*` calls with computed sizes → clamp to `>= 1`

---

## Verification checklist

- [ ] `monkeyc -f monkey.jungle -d fenix6 -o bin/watchface.prg -y developer_key.der` — no errors
- [ ] Same for: fenix6s, fenix6xpro, fr245, fr945, marq2
- [ ] Simulator fenix6: dark topo background visible
- [ ] Simulator: left gauge (tick marks + progress arc) visible on left side
- [ ] Simulator: right gauge visible on right side  
- [ ] Simulator: hour and minute hands have three-layer structure (white body + tan inlay + dark tail)
- [ ] Simulator: second hand visible in active mode, hidden in ambient mode
- [ ] Simulator: steps field shows number (or "--") and footprint icon
- [ ] Simulator: heart rate field shows number (or "--") and heart icon
- [ ] Simulator: sub-dial circle with sunset/elevation icons and text
- [ ] Simulator: date box with colored day number and battery icon
- [ ] No crashes on null data (no steps, no HR, no GPS)

---

## Do not

- Commit (`git push` or `git commit`). Staging with `git add` is allowed.
- Use any fonts other than Connect IQ system fonts.
- Add permissions not listed above.
- Put any drawing code in Logic or Delegate files.
- Put any business logic or data fetching in Draw* files.
- Use magic numbers — all constants go in `Constants.mc`.
