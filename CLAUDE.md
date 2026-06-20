# CLAUDE.md

Working agreement for AI-assisted changes in this repository. Read fully before touching code.

## 1. Project snapshot

- Platform: Garmin Connect IQ
- Language: Monkey C
- App type: widget
- Target SDK: Connect IQ 3.1.0 (minApiLevel 3.1.0)
- Target devices: fenix6, fenix6s, fenix6x, fr245, fr945
- Build tool: Monkey C compiler (`monkeyc`)

For project overview, build instructions, and runtime behaviour see `README.md`.

## 2. Workflow

Every change goes through five stages in order:

1. Plan
2. Approval
3. Implementation
4. Verification
5. Documentation

Implementation does not start without explicit approval of the plan.

### Plan contents

- Goal: what changes and why
- Affected files (`source/`, `resources/`, `manifest.xml`)
- Steps in execution order
- Verification checklist

### Where the plan lives

In chat. Plans are not committed to the repository.

### Definition of done

A task is closed only when all of the following hold:

- Code compiles without errors on all target devices
- Verified in the simulator on at least one target device
- `README.md` reflects new behaviour if it changed

A task is not done if any of these is missing, even when the code looks correct.

### Plan-free exceptions

Trivial edits do not require an upfront plan: string copy fixes, single-line constant changes, formatting-only changes.

## 3. Architecture and file structure

### File layout

```
source/
  <Name>App.mc        — entry point (AppBase subclass)
  <Name>View.mc       — rendering (WatchUi.View subclass; onUpdate only)
  <Name>Delegate.mc   — input handling (BehaviorDelegate subclass)
  <Name>Logic.mc      — business logic, data, computations
  Constants.mc        — shared constants
resources/
  strings/strings.xml — all user-facing strings
  layouts/            — layout XMLs (optional)
  images/             — PNG assets
manifest.xml          — app metadata, target devices, permissions, API level
monkey.jungle         — build targets for multi-device compilation
```

### Layer rules

- `View` — rendering only. No business logic, no data fetching, no state mutation. Calls into Logic or receives precomputed state as parameters.
- `Delegate` — input events only. Triggers actions, does not compute results.
- `Logic` / data classes — all business logic, data transformation, system API calls (`ActivityMonitor`, `Sensor`, `System`, etc.). No drawing code (`dc.*` calls).
- New files are extracted when a single file grows beyond ~200 lines or when a clear domain boundary appears.

### Coding rules

- Monkey C is weakly typed. Annotate types explicitly where the language allows (`as Type`).
- Check for `null` before dereferencing any value that can be `null`. Never assume a system API returns a non-null value.
- All user-facing text goes through `resources/strings/strings.xml`. No hard-coded strings in source files.
- Shared constants go in `Constants.mc`. Do not scatter magic numbers or string keys across files.

## 4. Verification

Connect IQ has no automated unit-test framework. Verification is manual, in the Garmin simulator.

### Checklist before closing a task

- [ ] Compiles without errors: `monkeyc -f monkey.jungle -d <device> -o bin/widget.prg -y developer_key.der`
- [ ] Runs without crashes in the simulator on at least one round-face target (fenix6)
- [ ] Expected data is displayed correctly at all screen sizes of targeted devices
- [ ] Edge cases pass: no data available, permission denied, extreme values
- [ ] UI text is visible and not truncated

### When the change touches device-specific layout or rendering

Run the simulator check on each device family the change affects: round (fenix6), non-round GPS (fr245).

## 5. Documentation

- `README.md` at the repo root: what the widget does, how to build, how to run in the simulator, target devices.
- Update `README.md` in the same task when behaviour changes.

### Specs (ТЗ)

- Specs live **outside** the repository: `~/Documents/Claude/Projects/GarminWatchfaces/specs/`
- Specs are **never** committed or pushed to the repo. The `specs/` folder is listed in `.gitignore`.
- Filename: `<TICKET>-<short-kebab-title>.md`. Ticket prefix: `WDG-NN` for widget features, `FIX-NN` for bug fixes.
- Specs are written in Russian, in behavioural/product framing — sections: `Цель`, `Контекст`, `Функциональные требования`, `Acceptance criteria`, `Открытые вопросы`.
- A spec is created before implementation and is the source for the plan (section 2).

### Работа в трёх режимах

Переход между режимами — только по явной команде пользователя.

**Режим 1 — Обсуждение требований.** Активируется когда пользователь описывает новую идею.
- Задавать уточняющие вопросы по одному, не списком.
- Цель: выявить функциональные требования для последующей спеки.
- Не предлагать решения и не писать код в этом режиме.

**Режим 2 — Написание спеки.** Активируется командой «пиши спеку» или «режим 2».
- Написать MD-файл спеки на основе собранных требований.
- Уровень системного аналитика: поведение и продуктовая логика, без деталей реализации.
- Сохранить в `~/Documents/Claude/Projects/GarminWatchfaces/specs/<TICKET>-<name>.md`.
- Не трогать кодовую базу в этом режиме.

**Режим 3 — Написание промта на реализацию.** Активируется командой «пиши промт» или «режим 3».
- Прочитать спеку и кодовую базу.
- Применить скилл `spec-plan`: проверить ограничения, составить план, выдать implementation prompt.
- Не писать код напрямую — только промт для агента.

## 6. Commands

```bash
# Compile for a specific device
monkeyc -f monkey.jungle -d fenix6 -o bin/widget.prg -y developer_key.der

# Compile for all devices (check manifest.xml for list)
# Run for each: fenix6, fenix6s, fenix6x, fr245, fr945

# Run simulator
connectiq
```

Before closing a task: compilation must succeed for all target devices in `manifest.xml`.

## 7. Do not

- Run `git commit` or `git push` without explicit approval from the user. Staging with `git add` is allowed.
- Commit files under `bin/`, `*.prg`, `*.iq` — these are build outputs.
- Commit or push specs. Specs live in `~/Documents/Claude/Projects/GarminWatchfaces/specs/` and are gitignored.
- Hard-code user-facing strings. All UI text goes through `resources/strings/strings.xml`.
- Add Connect IQ permissions to `manifest.xml` without explicit approval.
- Change widget colours, layout, or visual design without an explicit visual task.
- Use Connect IQ API calls not supported by `minApiLevel 3.1.0` without approval to raise the minimum level.
- Put drawing code (`dc.drawText`, `dc.setColor`, etc.) in Logic or Delegate files.
- Put business logic or system API calls in View or Delegate files.

## 8. Current state vs target

**Current state:**
- Single source file `GarminWidgetApp.mc` containing App, View, and Delegate — no layer separation.
- No `monkey.jungle` build file; multi-device build not set up.
- `README.md` is a one-line placeholder.

**Target state:**
- Logic separated from View and Delegate into dedicated files per the rules in section 3.
- `monkey.jungle` in place for multi-device compilation.
- `README.md` describes the widget, build steps, and simulator usage.

The rules in this document apply in full from the first real feature task onwards. The current single-file structure is refactored as part of that first task, not as a separate chore.
