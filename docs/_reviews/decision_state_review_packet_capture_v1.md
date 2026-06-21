# Decision-State Review Packet Capture v1

## Scope

Local-only evidence capture on main at `682634c2b142afcee43779e80b22d07d14059cec`.
No product UI, copy, behavior, tests, or navigation changed. Generated images,
the contact sheet, manifest, and zip remain local-only.

## Why this packet exists

The core surface packet proves the static roles of Home, Learn, Practice,
Review, and Profile, but it does not prove the decision-to-repair loop. This
pass checked whether the existing deterministic capture lanes expose the
missing decision and feedback states without adding a new capture system.

## Capture method

Command used:

```bash
./tools/screen_review_fast_v1.sh core compact
```

The fast lane is the existing Flutter widget-test real-text capture pipeline.
It currently accepts only `core compact` and captures Home, Learn, Practice,
Review, and Profile. A narrow existing-helper fix created the missing final
output parent before its atomic staging-directory rename; all five PNGs were
already rendered successfully before that rename failed.

Local artifacts:

- `output/screen_review/current/core_fast/compact.review.png`
- `output/screen_review/current/core_fast/contact_sheet.png`
- `output/screen_review/current/core_fast/screen_review_core_fast.zip`
- `output/screen_review/current/core_fast/manifest.json`

## State evidence

| Requested state | Capture result | Evidence / limitation |
| --- | --- | --- |
| Decision / answer choice | Not captured | `runnerDrill` exists in `Act0ControlledDemoCaptureSurfaceV1`, but the supported fast command has no runner-state argument. |
| Correct feedback | Not captured | `runnerFirstCorrectFeedback` exists in the deterministic debug enum, but is not exposed by the supported fast command. |
| Wrong feedback with Repair focus | Not captured | `runnerFirstWrongFeedback` exists in the deterministic debug enum, but is not exposed by the supported fast command. |
| Repair attempt / Repair result | Not captured | The runner renders `Repair result`, but there is no dedicated deterministic capture surface for a resolved repair attempt. |
| Session repair summary | Not captured | The runner renders `Session repair`, but there is no dedicated deterministic capture surface for this resolved-session state. |
| Review handoff / repair continuation | Captured | `compact.review.png` visibly shows `What to fix next`, the `Repair coach` card, a next focused hand, and the `Repair this clue` CTA. |

The earlier web/Playwright controlled-demo lane has runner capture URLs but is
not a safe fallback for this packet: its active surface list does not include
the first-wrong-feedback state and prior capture work established that the
lane can stop at placement or return unusable output. It was not revived for
an evidence-only pass.

## Visible result

The captured Review handoff is readable at compact size and presents repair as
a single learner-facing continuation rather than a dashboard. It does not,
however, provide proof of the answer-choice state, either feedback outcome,
the Repair result receipt, or the Session repair receipt.

## Recommended next step

Keep this packet as a boundary record. If decision-loop visual proof becomes a
release or product-review requirement, scope a separate, narrow extension of
the existing real-text fast lane that exposes the existing `runnerDrill`,
`runnerFirstCorrectFeedback`, and `runnerFirstWrongFeedback` debug entries.
Do not invent repair-result or session-summary state in capture tooling until
the app exposes a named deterministic state for each resolved lifecycle
outcome.
