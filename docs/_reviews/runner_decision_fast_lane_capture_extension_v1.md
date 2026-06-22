# Runner Decision Fast-Lane Capture Extension v1

## Scope

Local-only capture-tooling extension on main. No Act0 product UI, copy,
behavior, runner business state, or tests changed. Generated artifacts remain
local-only and uncommitted.

## Existing deterministic states

`Act0ControlledDemoCaptureSurfaceV1` already provides these direct runner
entries in `act0_shell_preview_screen_v1.dart`:

- `runnerDrill` for the answer-choice state;
- `runnerFirstCorrectFeedback` for the first correct-feedback state;
- `runnerFirstWrongFeedback` for the first wrong-feedback state.

## Capture command

```bash
./tools/screen_review_fast_v1.sh runner compact
```

The command reuses the existing Flutter widget-test renderer, staging lifecycle,
manifest, contact-sheet, and zip packager. `core compact` remains unchanged for
daily five-surface review. The runner group writes to its own packet directory.

## Local artifacts

- `output/screen_review/current/runner_fast/compact.decision.png`
- `output/screen_review/current/runner_fast/compact.correct_feedback.png`
- `output/screen_review/current/runner_fast/compact.wrong_feedback.png`
- `output/screen_review/current/runner_fast/contact_sheet.png`
- `output/screen_review/current/runner_fast/screen_review_runner_fast.zip`
- `output/screen_review/current/runner_fast/manifest.json`

## Evidence result

| Requested proof | Result | Evidence / limitation |
| --- | --- | --- |
| Decision / answer choice | Captured | `compact.decision.png` shows the table, hero seat, task prompt, and answer interaction. |
| Correct feedback | Captured | `compact.correct_feedback.png` shows the correct outcome, clue, best play, and value receipt. |
| Wrong feedback | Captured | `compact.wrong_feedback.png` shows the missed clue, better option, and repair-oriented next step. |
| Repair focus | Not captured | `runnerFirstWrongFeedback` selects a wrong option but does not create a repair intent. The `Repair focus` block is only shown when a repair reason exists. No named deterministic debug entry currently combines the resolved wrong feedback with that intent. |
| Repair result | Not captured | No named deterministic capture entry represents a resolved repair attempt. |
| Session repair | Not captured | No named deterministic capture entry represents the resolved session summary. |

The runner images preserve the existing renderer limitation where the bottom
feedback CTA label can appear blank. This extension does not alter rendering,
product UI, or copy; the decision and feedback content above the CTA remains
readable.

## Next step

Use `runner compact` for decision, correct-feedback, and wrong-feedback visual
review. If Repair focus, Repair result, or Session repair proof becomes a
release requirement, first add named deterministic capture entries through a
separate, explicitly scoped runner-state seam; do not synthesize those states
inside the capture tool.
