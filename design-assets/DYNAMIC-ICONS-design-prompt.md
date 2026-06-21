# Design brief — dynamic watch-face elements (battery, side gauges, bottom ring)

You are a design agent producing **raster PNG assets** for a Garmin **MARQ 2** Connect IQ
analog watch face ("Adventurer"), dark/outdoor theme. This document both **stores the design**
and tells you exactly **what files to create**.

These three elements are **dynamic** (they change with live data), so they cannot be a single
static image. Connect IQ also can't rotate/scale bitmaps cheaply, and big multi-frame sprite
sheets blow the memory budget. Therefore each dynamic element is delivered as **layers**:
a static crisp **track** PNG + a static **fill** PNG, and the code reveals the live portion.
The battery is delivered as an **outline** PNG + a code-drawn fill bar.

---

## 0. Global specs (apply to every file)

- **Format:** PNG-32 (RGBA), **fully transparent background**. Straight (non-premultiplied) alpha.
- **Reference canvas:** **1000 × 1000**, origin top-left, **centre (500, 500)** — same convention
  as the watch geometry. Draw each element at its real on-watch position inside this canvas;
  leave the rest transparent. (The engine downscales 1000→device px: marq2 390, fenix6xpro 280,
  others 240. Provide art at **2000 × 2000** for headroom; same layout, just 2×.)
- **Anti-aliasing:** on. Colours are **final/baked** (bitmaps are not recoloured at runtime),
  except where a colour is explicitly "code-driven" (battery fill).
- **Angles:** measured **clockwise from 12 o'clock** (0°=top, 90°=3 o'clock, 180°=6, 270°=9).
- **A track+fill pair must share the exact same 1000×1000 registration** so they overlay perfectly.
- **No text baked in** except the gauge scale numbers `0 / 50 / 100` (part of the track).
- Deliver everything into `design-assets/`.

### Palette (hex)

| Token | Hex | Use |
|---|---|---|
| gradient-hot | `#f47233` | progress fill at 0%/bottom (bright orange) |
| gradient-cool | `#6e1a0b` | progress fill at 100%/top (dark red) |
| gauge-empty | `#33342e` | gauge unfilled band |
| frame-empty | `#2a2b25` | bottom-ring unfilled band |
| scale-tick | `#DAD4BA` | fine scale ticks |
| accent-cream | `#ECE6CE` | accent ticks (10/20/…/90 %) |
| accent-orange | `#E8521F` | accent ticks at 0 / 50 / 100 % |
| label | `#9a9b88` | scale numbers 0/50/100 |
| frame-outline | `#2e2f29` | thin outline ring (bottom frame) |
| tan | `#8C8E72` | battery outline |
| batt-low | `#E8521F` | (code) battery ≤20% |
| batt-crit | `#CC0000` | (code) battery ≤10% |

---

## 1. Battery  →  `battery-outline.png`

A horizontal battery **outline only**, interior **transparent** (the charge bar is drawn in code).

- Proportion (within a 130 × 74 sub-box, scale into the canvas at ~90 px wide on the 1000 ref):
  - **Shell:** rounded rectangle, x6 y16 **w104 h42**, corner-radius 7, **stroke only**, width 5, colour `tan`.
  - **Terminal nub:** filled rounded rect, x114 y28 **w9 h18**, radius 3, colour `tan`.
  - Interior fully transparent.
- Centre it horizontally; vertical placement on the watch is handled by code.
- **One file.** (The fill bar + its colour by charge level are drawn programmatically.)

---

## 2. Side gauges — `gauge-left-track.png` + `gauge-left-fill.png`,
##                  `gauge-right-track.png` + `gauge-right-fill.png`

Two thin segmented arcs hugging the **left** and **right** rim. Each is delivered as a
**track** (static decoration) + a **fill** (the full 100% gradient band).

### Geometry (radii are distance from centre 500, in 1000-canvas units)

- **Left arc** sweeps from **228° (bottom = 0%)** up through **270° (9 o'clock)** to
  **312° (top = 100%)**. **Right arc** is the mirror: **132° (bottom 0%) → 90° → 48° (top 100%)**.
- Radial bands (same for both gauges):
  - **scale ticks:** r **408 → 420** (short radial ticks, colour `scale-tick`, ~44 of them, evenly spaced)
  - **accent ticks:** r **386 → 422** (longer, 11 of them every 10%; colour `accent-cream`,
    except **0 / 50 / 100 %** which are `accent-orange`)
  - **progress band:** r **426 → 446** (the dynamic gradient band, ~56 segments)
  - **scale numbers** `100 / 50 / 0`: baseline radius ~**372**, at the top / middle / bottom of the
    arc, colour `label`, condensed sans (Rajdhani), small.

### `*-track.png` (static, always visible)
Scale ticks + the 11 accent ticks + the `0/50/100` numbers. **No progress band.** Transparent band area.

### `*-fill.png` (the full, 100%-filled progress band)
Only the **progress band** (r 426→446), rendered as the complete gradient from
**`gradient-hot` at the bottom (0% end)** smoothly to **`gradient-cool` at the top (100% end)**.
Everything else transparent. (At runtime the code shows this from 0→current%, and paints the
remainder with `gauge-empty`; so the *empty* colour does **not** go in this PNG.)

---

## 3. Bottom ring (daylight) — `frame-track.png` + `frame-fill.png`

A near-full **ring** wrapping the bottom sub-dial, with a **gap at the very bottom (6 o'clock)**.
Centre of the ring sits **below** the watch centre, around **(500, 760)** in the canvas; ring
radius ~**180–210** (a thin segmented band of ~121 short radial ticks). Gap ≈ the bottom ~50°.

- **`frame-track.png`:** the thin **outline ring** (`frame-outline`, 1–2 px) following the band,
  with the same bottom gap. (Static.)
- **`frame-fill.png`:** the full gradient band (same `gradient-hot`→`gradient-cool` sweep), running
  from the **bottom-left end (0%)** clockwise up and around to the **bottom-right end (100%)**,
  transparent elsewhere. Empty colour (`frame-empty`) is **not** baked — code paints the unfilled part.

---

## Deliverables checklist

```
design-assets/
  battery-outline.png          (1 file)
  gauge-left-track.png         gauge-left-fill.png
  gauge-right-track.png        gauge-right-fill.png
  frame-track.png              frame-fill.png
```

Rules recap: 1000×1000 (or 2000×2000) canvas, transparent bg, baked final colours, each
track+fill pair pixel-registered, no extra padding, anti-aliased. Gradient always
**hot (#f47233) at the 0% end → cool (#6e1a0b) at the 100% end**.
