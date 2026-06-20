---
name: code-review
description: Code-level review of changes staged for merge against main. Checks correctness, null safety, layer violations, resource handling, and Monkey C API misuse. Use when the user asks to review a diff or changes before merging, or says "посмотри код", "сделай ревью", "review my diff", "code review".
---

# Code Review — Garmin Connect IQ (Monkey C)

Reviews a diff against `main` for code-level issues. Focuses on correctness, safety, and adherence to CLAUDE.md rules. Does not review architecture, device compatibility, or performance — those are `compat-review` and `perf-review`.

## Workflow

### 1. Load project rules

Read `CLAUDE.md`. Extract layer rules, coding rules, and "Do not" constraints. These are the reference for all findings below.

### 2. Get the diff

```bash
git diff main...HEAD
```

If nothing is staged or the branch is clean, tell the user and stop.

### 3. Review the diff

Check each changed file against the following categories. Report only issues found — do not list categories with no findings.

#### Null safety

- Every value returned from a Connect IQ system API that can be `null` must be checked before use. Flag any dereference of a potentially-null value without a guard.
- Flag force-casts (`:as Type`) applied to values that can be `null`.

#### Type correctness

- Monkey C is weakly typed. Flag variables used as a different type than assigned without explicit cast.
- Flag missing type annotations on function parameters and return values where the language allows them.

#### Layer violations (CLAUDE.md §3)

- Flag any `dc.*` drawing calls outside of `View` files (`*View.mc`).
- Flag any system API calls (`ActivityMonitor.*`, `Sensor.*`, `System.*`, etc.) inside `View` or `Delegate` files.
- Flag any state mutation or computation inside `Delegate` files beyond triggering an action.

#### String hard-coding

- Flag any user-facing string literal in `.mc` files. All UI text must go through `strings.xml`.

#### Resource handling

- Flag any `open()` or `openFile()` calls without a corresponding `close()`.
- Flag timers started without a clear stop path.

#### API misuse

- Flag incorrect parameter types passed to Connect IQ APIs.
- Flag deprecated API usage if identifiable.
- Flag calls to `WatchUi.requestUpdate()` inside `onUpdate()` (causes infinite loop).

#### Logic correctness

- Flag off-by-one errors in loops or array indexing.
- Flag division by zero where the denominator can be 0.
- Flag unreachable code.

### 4. Report findings

For each finding:

```
### [Critical | Warning | Suggestion] — <short title>
**File:** <filename>, line <N>
<what the problem is and why it matters>
**Fix:** <concrete fix — code snippet if helpful>
```

Severity:
- **Critical** — will crash, produce wrong output, or violate a CLAUDE.md rule.
- **Warning** — likely to cause bugs under some condition.
- **Suggestion** — style or clarity improvement consistent with CLAUDE.md coding rules.

End the review with a one-line summary: number of criticals, warnings, suggestions.

## What this skill must not do

- Do not review device compatibility or API level — that is `compat-review`.
- Do not review memory or battery performance — that is `perf-review`.
- Do not propose new features or refactors beyond what the diff touches.
- Do not approve the diff — only report findings. The user decides whether to merge.
