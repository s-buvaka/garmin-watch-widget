# Convert SVG Icons to PNG Resources for Garmin Connect IQ

## Task

Convert SVG icon files to PNG bitmaps sized for each Garmin target device. The PNGs become bitmap resources in the Connect IQ project.

---

## Source files

All SVGs are in `design-assets/`:

| File | ViewBox | Description |
|------|---------|-------------|
| `icon-steps.svg` | 200×200 | Two footprints, fill #8C8E72 |
| `icon-heart.svg` | 100×100 | Heart shape, fill #8C8E72 |
| `icon-sunset.svg` | 120×100 | Sun + rays + horizon lines, fill/stroke #E8521F |
| `icon-elevation.svg` | 120×82 | Mountain ranges, stroke #8C8E72 |
| `icon-battery.svg` | 130×74 | Battery outline + fill, stroke/fill #8C8E72 |

---

## Target sizes

Each icon is rendered at a size proportional to the screen width of the device.

| Icon | Size formula | Reason |
|------|-------------|--------|
| steps | `screenW × 0.075` | small field icon |
| heart | `screenW × 0.075` | small field icon |
| sunset | `screenW × 0.085` | sub-dial icon |
| elevation | `screenW × 0.085` | sub-dial icon |
| battery | width `screenW × 0.10`, height proportional | inline in date box |

Device screen widths:
- **240px**: fenix6, fr245, fr945
- **232px**: fenix6s
- **280px**: fenix6xpro, marq2

Compute PNG pixel sizes for each icon × each screen width. Round to nearest integer. Transparent background.

---

## Output folder structure

```
resources/
  images/
    240/
      icon-steps.png
      icon-heart.png
      icon-sunset.png
      icon-elevation.png
      icon-battery.png
    232/
      icon-steps.png
      ...
    280/
      icon-steps.png
      ...
```

---

## Conversion method

Use `sharp`, `svgexport`, `Inkscape CLI`, `rsvg-convert`, or any tool available. The only requirement: correct pixel dimensions and transparent background (PNG-32 RGBA).

Example with `rsvg-convert`:
```bash
rsvg-convert -w 18 -h 18 icon-steps.svg -o icon-steps.png
```

Example with Inkscape:
```bash
inkscape --export-type=png --export-width=18 --export-height=18 \
  --export-filename=icon-steps.png icon-steps.svg
```

Example with Node `sharp`:
```js
const sharp = require('sharp');
await sharp(Buffer.from(svgString))
  .resize(18, 18)
  .png()
  .toFile('icon-steps.png');
```

---

## drawables.xml

After generating PNGs, add to `resources/drawables.xml`:

```xml
<bitmap id="IconSteps"     filename="images/icon-steps.png"/>
<bitmap id="IconHeart"     filename="images/icon-heart.png"/>
<bitmap id="IconSunset"    filename="images/icon-sunset.png"/>
<bitmap id="IconElevation" filename="images/icon-elevation.png"/>
<bitmap id="IconBattery"   filename="images/icon-battery.png"/>
```

---

## monkey.jungle — per-device resources

Map each device to its screen-size resource folder:

```
project.manifest = manifest.xml

fenix6.resourcePath   = $(fenix6.resourcePath);resources/images/240
fenix6s.resourcePath  = $(fenix6s.resourcePath);resources/images/232
fenix6xpro.resourcePath = $(fenix6xpro.resourcePath);resources/images/280
fr245.resourcePath    = $(fr245.resourcePath);resources/images/240
fr945.resourcePath    = $(fr945.resourcePath);resources/images/240
marq2.resourcePath    = $(marq2.resourcePath);resources/images/280
```

---

## Usage in Monkey C

Load in `onLayout`:
```monkeyc
_iconSteps     = WatchUi.loadResource(Rez.Drawables.IconSteps)     as WatchUi.BitmapResource;
_iconHeart     = WatchUi.loadResource(Rez.Drawables.IconHeart)     as WatchUi.BitmapResource;
_iconSunset    = WatchUi.loadResource(Rez.Drawables.IconSunset)    as WatchUi.BitmapResource;
_iconElevation = WatchUi.loadResource(Rez.Drawables.IconElevation) as WatchUi.BitmapResource;
_iconBattery   = WatchUi.loadResource(Rez.Drawables.IconBattery)   as WatchUi.BitmapResource;
```

Draw centered at position `(x, y)`:
```monkeyc
if (_iconSteps != null) {
    var bmp = _iconSteps as WatchUi.BitmapResource;
    dc.drawBitmap(x - bmp.getWidth() / 2, y - bmp.getHeight() / 2, bmp);
}
```

Replace all `dc.fillPolygon` icon drawing in `DrawDataFields.mc` and `DrawSubDial.mc` with `dc.drawBitmap` calls using these resources.

---

## Battery icon — special case

The battery icon needs to show charge level dynamically. Options:

**Option A (simple):** Generate 4 PNG variants — full, medium, low, critical — and pick at runtime based on `batteryPct`.

**Option B (programmatic):** Keep drawing it via `dc.drawRoundedRectangle`. The battery SVG is simple enough:
- Outer rect: `x=6 y=16 w=104 h=42 rx=7`, stroke `#8C8E72`
- Terminal: `x=114 y=28 w=9 h=18 rx=3`, fill `#8C8E72`
- Fill bar: `x=16 y=26 w=84×(pct/100) h=22 rx=3`, fill `#8C8E72` (orange `#E8521F` when ≤20%, red `#CC0000` when ≤10%)

Scale all values by `targetWidth / 130.0` where `targetWidth = screenW * 0.10`.

Option B is preferred — it avoids generating multiple PNG variants.

---

## Verification

After conversion:
1. `monkeyc -f monkey.jungle -d fenix6 -o bin/watchface.prg -y developer_key.der` — no errors
2. Open simulator on fenix6: icons appear sharp, correctly sized, no artifacts
3. Repeat on marq2 (280px) — icons larger, proportional
