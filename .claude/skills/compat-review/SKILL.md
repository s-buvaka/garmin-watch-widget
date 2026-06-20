---
name: compat-review
description: Compatibility review of changes staged for merge against main. Checks Connect IQ API level requirements, device-specific assumptions, and screen size compatibility. Use when the user asks "проверь совместимость", "compat review", "будет ли работать на всех девайсах", or after adding new system API calls.
---

# Compat Review — Garmin Connect IQ

Reviews a diff against `main` for device and API compatibility issues. Focuses exclusively on: Connect IQ API level, target device capabilities, and screen-size assumptions. Does not review code correctness or performance.

## Workflow

### 1. Load project context

Read `CLAUDE.md`. Note:
- `minApiLevel`: 3.1.0
- Target devices: fenix6, fenix6s, fenix6x, fr245, fr945

Read `manifest.xml` to confirm the current device list and permissions.

### 2. Get the diff

```bash
git diff main...HEAD
```

### 3. Check API level

For every Connect IQ API call introduced or changed in the diff:

- Identify the minimum API level at which that call is available (use Connect IQ API docs or web search if needed).
- Flag any call that requires an API level higher than `minApiLevel 3.1.0`.

```
### [Blocker | Warning] — API <ClassName.method> requires level X.X.X
**File:** <filename>, line <N>
This call was introduced in Connect IQ X.X.X. Current minApiLevel is 3.1.0.
**Options:**
  A. Raise minApiLevel to X.X.X — drops support for older firmware.
  B. Guard with a runtime version check: `System.getDeviceSettings().monkeyVersion`.
  C. Find an equivalent API available at 3.1.0.
```

### 4. Check permissions

For every system resource accessed in the diff (sensors, activity data, location, etc.):

- Check whether a Connect IQ permission is required.
- Check whether that permission is declared in `manifest.xml`.
- Flag any missing permission as a blocker.

### 5. Check device-specific assumptions

Target devices differ in screen shape, resolution, and sensor availability:

| Device   | Shape     | Resolution |
|----------|-----------|------------|
| fenix6   | round     | 260×260    |
| fenix6s  | round     | 240×240    |
| fenix6x  | round     | 280×280    |
| fr245    | round     | 240×240    |
| fr945    | round     | 240×240    |

Flag:
- Hard-coded pixel coordinates or sizes that assume a specific resolution.
- Layout or drawing logic that does not use `dc.getWidth()` / `dc.getHeight()` for positioning.
- Sensor or feature usage (heart rate, barometer, GPS) without checking `System.getDeviceSettings()` capabilities.
- Code that would render incorrectly at minimum screen size (240×240).

### 6. Report findings

```
### [Blocker | Warning | Info] — <short title>
**File:** <filename>, line <N>
<what the problem is>
**Options:** <if a blocker, list resolution options>
```

- **Blocker** — the feature will not work on at least one target device or will be rejected by the Connect IQ store.
- **Warning** — may work on most devices but will degrade or look wrong on some.
- **Info** — noteworthy but acceptable given current targets.

End with a one-line summary: blockers, warnings, info items found.

## What this skill must not do

- Do not review code correctness — that is `code-review`.
- Do not review memory or battery usage — that is `perf-review`.
- Do not raise minApiLevel or add permissions unilaterally — always flag as a blocker for user decision.
