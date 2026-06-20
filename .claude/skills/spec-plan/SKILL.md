---
name: spec-plan
description: Reads a spec file from ~/Documents/Claude/Projects/GarminWatchfaces/specs/, maps it to the codebase, checks Connect IQ constraints, produces an implementation plan, surfaces blockers, then emits a self-contained implementation prompt for another agent. Use whenever the user provides a spec path and asks to plan implementation, or says "разбери спеку", "план по спеке", "режим 3", "пиши промт".
---

# Spec Plan — Garmin Connect IQ

Interactive spec interpreter for Garmin Connect IQ (Monkey C). Takes a spec MD file, maps it to the codebase, validates against Connect IQ constraints, aligns with the user on blockers, then emits a single implementation prompt an agent can execute end-to-end.

## Input

Spec file path. If not provided, ask for it before proceeding. Specs live in `~/Documents/Claude/Projects/GarminWatchfaces/specs/`.

## Workflow

Follow these steps in order. Do not skip any.

### 1. Load project rules

Read `CLAUDE.md` at the repo root. Extract:

- Layer rules (what belongs in View, Delegate, Logic).
- Coding rules (null checks, type annotations, strings.xml).
- Target devices and `minApiLevel`.
- "Do not" constraints.
- Verification checklist (section 4).
- Definition of done (section 2).

These rules constrain every decision in this skill. A spec requirement that violates a CLAUDE.md rule is a blocker — not a suggestion.

### 2. Read the spec

Read the MD file. Extract:

- Goal: what this feature does for the user.
- Functional requirements: what the system must do.
- Edge cases and error states mentioned.
- UI/UX: what is displayed, when, and how.
- Anything ambiguous or underspecified — mark each gap explicitly.

### 3. Map spec to codebase

Explore the current codebase:

- List source files: `find source/ -name "*.mc" | sort`
- Read relevant files (View, Logic, manifest.xml, strings.xml).
- Identify for each requirement:
  - **Reuse** — existing code that works as-is.
  - **Extend** — existing code that needs modification.
  - **Create** — new files or classes.

For each "Create" item, determine the correct layer per CLAUDE.md §3.

### 4. Check Connect IQ constraints

For every system API the spec implies, verify:

- **API level** — is the call available at `minApiLevel 3.1.0`? Check the Connect IQ API docs if needed. Flag anything requiring a higher level as a blocker.
- **Permissions** — does the spec require a permission not in `manifest.xml`? Flag as a blocker requiring approval.
- **Memory** — does the feature involve large data structures, long loops, or frequent allocations? Flag as a risk.
- **Device compatibility** — does the feature assume a specific screen shape, size, or sensor not present on all target devices? Flag as a blocker or risk.
- **onUpdate frequency** — does the spec imply real-time updates? Note the minimum update interval and whether a timer is needed.

### 5. Build the plan

```
## Goal
<one or two sentences from the spec>

## Affected files
<list: path — action (create/modify) — reason>

## Execution steps
<ordered list; each step names the file(s) it touches>

## Verification
<checklist items from CLAUDE.md §4 relevant to this feature>

## Strings to add
<list of string keys and values to add to strings.xml>
```

### 6. Surface blockers and risks

**Blockers** — must be resolved before implementation:
- API not available at minApiLevel 3.1.0.
- Permission not in manifest.xml.
- Spec requirement that violates a CLAUDE.md rule.
- Technical ambiguity with no safe default.

**Risks** — possible but likely to cause bugs:
- Memory allocation patterns on constrained heap.
- Logic in View or Delegate files.
- Race conditions from timer callbacks.
- Assumptions about sensor availability across all target devices.

**UX concerns** — spec gaps or inconsistencies:
- Missing empty state, error state, or loading state.
- Text not defined in strings.xml.
- Layout assumptions that break on small screens (fr245: 240×240).

For each item:
```
### [Blocker | Risk | UX] — <short title>
<what the problem is and where in the spec it comes from>
**Options:**
  A. <option and trade-off>
  B. <option and trade-off>
```

### 7. Present and align

Output:
1. The plan from step 5.
2. Blockers, risks, and UX concerns from step 6.
3. Numbered questions, one per unresolved item.

Wait for user answers before proceeding. Every blocker must be resolved. Risks and UX concerns may be explicitly deferred.

### 8. Emit the implementation prompt

After all blockers are resolved, emit a single self-contained prompt in chat (not to a file).

The prompt must:

- Open by re-reading `CLAUDE.md` before touching any file.
- Name every file to create or modify with its relative path.
- Describe each change concretely (class name, method name, data fields, string keys).
- Reference every user decision from step 7.
- List string keys to add to `strings.xml`.
- Include the verification checklist from CLAUDE.md §4.
- Restate all "Do not" rules from CLAUDE.md §7.
- End with: "Do not commit. Report a short summary of every file touched and the result of each verification step."

## Implementation prompt template

```
You are an AI agent implementing a feature in a Garmin Connect IQ widget project (Monkey C).
Re-read CLAUDE.md at the repo root before touching any file. Its rules override everything below.

## Goal
<goal>

## Files to create or modify
<list: relative path — create/modify — what changes>

## Execution steps
<ordered steps incorporating all user decisions>

## Strings to add to resources/strings/strings.xml
<list of keys and values>

## User decisions already made
<list of resolved blockers and choices>

## Deferred concerns
<list of risks/UX items the user chose to defer>

## Verification (from CLAUDE.md §4)
- Compiles without errors for all target devices in manifest.xml
- Runs in simulator on fenix6 without crashes
- Edge cases pass: <list specific to this feature>
- UI text visible and not truncated

## Do not (from CLAUDE.md §7)
- git commit or git push without explicit approval.
- Commit bin/, *.prg, *.iq files.
- Commit specs.
- Hard-code strings — all text goes through strings.xml.
- Add permissions to manifest.xml without approval.
- Change visual design without an explicit visual task.
- Use APIs not available at minApiLevel 3.1.0 without approval.
- Put drawing code in Logic or Delegate files.
- Put business logic in View or Delegate files.

Do not commit. Report a short summary of every file touched and the result of each verification step.
```

## What this skill must not do

- Do not begin implementation. This skill only plans and prompts.
- Do not silently resolve a blocker. Every blocker requires an explicit user answer.
- Do not emit the implementation prompt until all blockers are resolved.
- Do not invent requirements not present in the spec.
- Do not propose adding a new permission or raising minApiLevel without flagging it as a blocker.
