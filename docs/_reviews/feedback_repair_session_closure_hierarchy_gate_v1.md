# Feedback / Repair / Session Closure Hierarchy Gate v1

Terminal verdict: `feedback_hierarchy_bounded_wrong_feedback_context_recession_implemented`

## State and scope

- Step 0: `7ea40d882f149ed66484e6ecba312ef6910baebc` (Wave A evidence
  integrity) was confirmed on
  `origin/claude/hub-surface-coherence-audit-plan-v1` before this work.
- Branch / HEAD before: `claude/hub-surface-coherence-audit-plan-v1` /
  `7ea40d882f149ed66484e6ecba312ef6910baebc`.
- Branch / HEAD after: recorded by the Wave C commit that contains this
  artifact.
- Admitted files:
  - `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
  - `test/guards/feedback_repair_session_closure_hierarchy_gate_v1_test.dart`
  - this artifact.

No Home, Learn, Worlds, Profile, Practice, Review hub, Sharky asset, route,
progression, telemetry, W13, motion, tablet, or Human-QA change is included.

## State map

| State | Active presentation owner | Current disposition |
| --- | --- | --- |
| Correct feedback | `Act0FeedbackShellV1` in `act0_lesson_runner_shell_v1.dart` | Keeps the full-strength table and existing proof-to-next-action receipt. |
| Wrong feedback | Same feedback shell plus the runner-stage table wrapper | **Changed:** table remains the visible clue context but is statically dimmed; card owns the learning hierarchy. |
| Repair focus | Same feedback shell when `repairReasonLine` is present | Unchanged; existing visible repair-reason branch remains claim-safe. |
| Repair result | Same shell when `repairResultReceiptLine`/outcome proof is present | Unchanged; receipt stays source-backed. |
| Session repair | Same shell through `repairSessionSummaryLines` | Unchanged; ceremony/proof block remains existing behavior. |
| Session summary | Session-summary section of the same owner family | Unchanged; no new proof, achievement, or return semantics. |
| W12 payoff / no-W13 terminal | Completion/terminal route plus campaign source | Inspected only. Terminal is still claim-safe and W13 remains locked. |

## Decision gate and implementation

The observed problem was bounded enough to fix without a runner redesign: the
wrong-feedback table inherited the same visual strength as an active decision,
while the already-good feedback card carried the missed clue, better action,
table reason, and repair CTA.

The runner now computes
`shouldDeemphasizeTableForWrongFeedback` only for non-rapid wrong-review
states. It wraps the unchanged `_RunnerTableStageV1` in a static `Opacity`:

- wrong feedback: `0.68` opacity;
- correct, repair focus/result, session closure, W12, and all decision states:
  `1.0` opacity.

This is intentionally not motion, a table-layout change, or a data/repair
semantic change. The table stays available as context; the feedback card is
visually primary and retains its existing order:

`Missed clue -> Better option -> Clue from table -> explanation -> Try same clue`.

Correct feedback remains distinct: it keeps full-strength table context and
its existing positive proof receipt. No shame, punishment, fake proof,
mastery, achievement, score, or route behavior was added.

## Terminal/no-W13 inspection

The observed `You can now slo...` center chip is a real compact copy-fit debt,
not a capture artifact: the source-owned terminal context string is
`You can now slow down and read the table before choosing.` and the constrained
table cue abbreviates it. The W12 terminal test confirms no layout overflow and
the terminal route remains claim-safe/W13-blocked. This wave does not alter
campaign copy or table cue allocation; return it only in a dedicated
terminal/table copy-fit decision.

## Validation

- `flutter test test/guards/feedback_repair_session_closure_hierarchy_gate_v1_test.dart test/ui_v2/act0_result_feedback_rhythm_surface_v1_test.dart test/ui_v2/act0_w12_terminal_payoff_v1_test.dart` — 23 passed.
- `./tools/screen_review_fast_v1.sh runner compact` — passed; two real-text
  labels repaired by the existing capture lifecycle.
- `flutter analyze` — no issues.
- `git diff --check` — passed before commit.
- `graphify hook-check` — passed.
- staged diff check — required before commit.

Known unrelated legacy-test debt (not repaired in this owner wave):

- `Correct first-value feedback shows skill receipt from signal` expects the
  historical exact text `Correct` and fails because the direct
  `Act0FeedbackShellV1` fixture now emits current feedback copy.
- `Wrong first-value feedback uses repair skill receipt copy` likewise expects
  the historical exact text `Table clue` from that direct fixture.

Both tests mount `Act0FeedbackShellV1` directly and do not mount the
`Act0LessonRunnerShellV1` table wrapper changed here. The green 23-test focused
package exercises the current feedback and terminal contracts. Repairing the
two stale exact-copy assertions is outside this hierarchy-only wave.

## Compact evidence

Local-only, uncommitted evidence:

- Wrong feedback: `output/screen_review/current/runner_fast/compact.wrong_feedback.png`
- Correct feedback control: `output/screen_review/current/runner_fast/compact.correct_feedback.png`
- Contact sheet: `output/screen_review/current/runner_fast/contact_sheet.png`
- Packet ZIP: `output/screen_review/current/runner_fast/screen_review_runner_fast.zip`

Open commands:

```bash
open output/screen_review/current/runner_fast/compact.wrong_feedback.png
open output/screen_review/current/runner_fast/compact.correct_feedback.png
open output/screen_review/current/runner_fast/contact_sheet.png
```

## Return queue

| ID | Debt | Owner / timing |
| --- | --- | --- |
| CL-010 | Repair result, session repair, and session summary need a later unified proof -> action composition pass. | Future bounded closure wave; no new semantics. |
| TERM-010 | The full terminal center-cue string truncates in the compact table chip. | Dedicated terminal/table copy-fit decision only. |
| FB-010 | Wrong-feedback table is now visually receded; assess native-device fidelity only at a later device-proof gate. | Evidence-only follow-up, not tablet work. |

No 10/10 claim, public-readiness claim, Human-QA-readiness claim, or tablet
quality claim is made.
