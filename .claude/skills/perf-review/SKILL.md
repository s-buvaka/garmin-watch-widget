---
name: perf-review
description: Performance and battery review of changes staged for merge against main. Checks memory usage, onUpdate cost, timer usage, and battery impact specific to Garmin wearables. Use when the user asks "проверь производительность", "perf review", "не будет ли жрать батарею", or after adding timers, loops, or frequent updates.
---

# Perf Review — Garmin Connect IQ

Reviews a diff against `main` for performance and battery impact issues specific to Garmin wearables. Focuses exclusively on memory, draw call cost, update frequency, and battery. Does not review correctness or compatibility.

## Context: Garmin hardware constraints

- **Heap limit**: ~256 KB on older devices (fenix6 family). Large allocations or retained collections can cause out-of-memory crashes.
- **onUpdate budget**: The system calls `View.onUpdate()` on a schedule. Heavy computation here delays rendering and drains battery.
- **Timer resolution**: `Timer.Timer` minimum interval is ~1 second. Sub-second update loops are not possible and should not be simulated with tight timers.
- **Background execution**: Widgets are suspended when not in the glance/full view. Timers stop. Any background work (sensors, periodic data) must be explicitly managed.
- **Draw calls**: Each `dc.*` call has a cost. Minimise calls inside `onUpdate()`; prefer pre-computing values before entering the draw loop.

## Workflow

### 1. Load project context

Read `CLAUDE.md` — note layer rules (Logic vs. View separation).

### 2. Get the diff

```bash
git diff main...HEAD
```

### 3. Check memory usage

- Flag `new` allocations inside `onUpdate()` or inside tight loops. Prefer allocating once (in `initialize()` or `onShow()`) and reusing.
- Flag large arrays or dictionaries retained in instance variables. Estimate size where possible.
- Flag string concatenation in loops (creates many short-lived objects).
- Flag recursive functions — Monkey C stack is shallow.

### 4. Check onUpdate cost

- Flag any computation in `onUpdate()` that could be pre-computed and cached: date formatting, string building, math operations on static data.
- Flag system API calls inside `onUpdate()` that return data changing less frequently than the redraw rate (e.g., reading `ActivityMonitor` every frame).
- Flag nested loops inside `onUpdate()`.

### 5. Check timer usage

- Flag `Timer.Timer` intervals shorter than ~1 second.
- Flag timers started in `onShow()` without a corresponding stop in `onHide()` — timers running while the widget is hidden waste battery.
- Flag multiple redundant timers doing the same work.
- Flag timer callbacks that trigger `WatchUi.requestUpdate()` at a rate higher than needed for the displayed data.

### 6. Check update frequency

- Flag `WatchUi.requestUpdate()` called more often than the displayed data changes. If the widget shows minute-level data, requesting updates every second is wasteful.
- Flag `onUpdate()` calls that redraw the entire screen when only a portion has changed (full-screen redraw is acceptable if unavoidable in Connect IQ, but note if it seems excessive).

### 7. Check battery impact

- Flag any sensor subscription (`Sensor.setEnabledSensors`) left enabled when the widget is hidden.
- Flag GPS or heart-rate monitoring started without a clear stop condition.
- Flag high-frequency data polling that could be replaced with event-driven updates.

### 8. Report findings

```
### [Critical | Warning | Suggestion] — <short title>
**File:** <filename>, line <N>
<what the problem is and the estimated impact>
**Fix:** <concrete change — code snippet if helpful>
```

- **Critical** — likely to cause OOM crash or significant battery drain (e.g., sensor running in background indefinitely).
- **Warning** — will degrade performance or battery noticeably under normal use.
- **Suggestion** — minor optimisation or cleanup aligned with best practices.

End with a one-line summary: criticals, warnings, suggestions found.

## What this skill must not do

- Do not review code correctness — that is `code-review`.
- Do not review API level or device compatibility — that is `compat-review`.
- Do not propose architectural changes beyond what is needed to fix the identified performance issue.
