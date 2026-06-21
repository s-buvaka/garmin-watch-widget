# Garmin Marq 2 Adventurer Classic Watchface

An analog Garmin Connect IQ **watchface** (Monkey C) with an outdoor/adventure theme.

## What it shows

- Analog hour, minute and second hands (metallic SVG-derived shapes) over a topographic background
- **Left side gauge** — steps progress toward the daily goal (gradient arc + scale + 0/50/100 labels)
- **Right side gauge** — heart rate as a fraction of max HR (mirror of the left)
- **Bottom sub-dial** — sunrise/sunset times with a sunset icon, and temperature with an elevation icon
- **Date box** — `DAY DD MON` with the day number accented, plus an inline battery icon
- **Steps field** (footprint icon + count) and **Heart-rate field** (heart icon + bpm)

The second hand is drawn only while the watch is awake (high-power mode); it is hidden in low-power/sleep mode to save battery.

## Target devices

`fenix6`, `fenix6s`, `fenix6xpro`, `fr245`, `fr945`, `marq2` — Connect IQ SDK (`minApiLevel 3.3.0`, required by the Weather sunrise/sunset and temperature APIs).

## Project structure

```
source/
  AdventurerApp.mc       — AppBase entry point
  AdventurerView.mc      — WatchFace coordinator (fetches data, calls Draw* in order)
  AdventurerDelegate.mc  — WatchFaceDelegate
  AdventurerLogic.mc     — data fetching & computations (no drawing)
  Constants.mc           — colors, layout fractions, gauge geometry
  DrawBackground.mc      — topo PNG background
  DrawGaugeLeft.mc       — left side gauge (steps progress)
  DrawGaugeRight.mc      — right side gauge (heart-rate progress)
  DrawSubDial.mc         — bottom sub-dial (sunset/elevation icons + text)
  DrawDataFields.mc      — date box, battery, steps & heart-rate fields
  DrawHands.mc           — hour/minute/second hands + center cap
design-assets/           — reference SVGs (icons, side-gauges) — not compiled
resources/
  strings/strings.xml    — UI labels
  drawables.xml          — background bitmap declarations
  images/                — background_240/260/280 PNGs
manifest.xml
monkey.jungle
```

## Build

Compile for a single device (requires a developer signing key):

```bash
monkeyc -f monkey.jungle -d fenix6 -o bin/fenix6.prg -y developer_key.der
```

Repeat for each target: `fenix6`, `fenix6s`, `fenix6x`, `fr245`, `fr945`, `marq2`.

## Run in the simulator

```bash
connectiq                                  # start the simulator
monkeydo bin/fenix6.prg fenix6             # load the build onto a device
```
