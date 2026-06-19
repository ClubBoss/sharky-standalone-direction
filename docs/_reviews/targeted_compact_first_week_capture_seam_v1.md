# Targeted Compact First-Week Capture Seam v1

## Purpose

Create a bounded compact-portrait proof lane for the First Week Progression surfaces without running the broad controlled-demo screenshot sweep.

## Chosen capture seam

Added a targeted browser capture command:

```bash
tools/act0_first_week_compact_capture_v1.sh
```

The command uses the existing Act0 debug harness and Playwright CLI, but only targets the first-week compact proof states. It does not call `tools/act0_controlled_demo_capture_v1.sh`.

## Target states

| Surface | Debug URL | Expected proof |
| --- | --- | --- |
| Home first-week trainer | `?act0_capture=first_week_home` | `Week 1: build table-reading habits` |
| Review open repair | `?act0_capture=first_week_review` | `Week 1 repair` / open repair proof |
| Learn first-week path | `?act0_capture=first_week_learn` | `Your first week is about seeing the table before choosing.` |
| Profile return rhythm | `?act0_capture=first_week_profile` | `Week 1: each short return keeps one table clue warm.` |

## Commands used

```bash
flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name "First-week compact capture command stays targeted"
flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name "Controlled demo capture query accepts first-week proof surfaces"
bash -n tools/act0_first_week_compact_capture_v1.sh
tools/act0_first_week_compact_capture_v1.sh
```

## Screenshot output paths

No successful final screenshot inventory was produced in this run.

The first corrective changed the script to launch Playwright at `about:blank` and navigate inside each surface probe, avoiding the fragile direct daemon launch against a localhost app URL.

The targeted capture command now gets past browser launch in a traced run, but normal execution is still blocked locally by process termination:

```text
tools/act0_first_week_compact_capture_v1.sh
exit code 137
```

Previous and related failures included:

```text
Daemon process exited with code 1
Target page, context or browser has been closed
exception while trying to kill process: Error: kill EPERM
```

## Scope guard

- Compact phone only: `393 x 852`.
- Four states only.
- No broad default/json/assets portrait/landscape regeneration.
- No production UX, copy, route, telemetry, table geometry, commerce, entitlement, or Playwright tooling redesign.
- Existing generic capture URLs remain available and unchanged.

## Known limitations

- Flutter canvas text is not always available through `body.innerText`; the script records semantic text visibility as a warning rather than using it as the screenshot gate.
- Review and Profile require deterministic scroll offsets to frame the requested proof line.
- Current run is blocked by local process termination during the targeted script. A traced diagnostic run showed Playwright can launch at `about:blank` and reach the first surface probe, but normal execution is still killed before screenshot inventory is produced.

## Next recommended proof/review step

Run a bounded local process-environment pass for the targeted capture CLI, then rerun:

```bash
tools/act0_first_week_compact_capture_v1.sh
```

Do not run the broad controlled-demo sweep until the targeted compact lane can launch Chrome consistently.
