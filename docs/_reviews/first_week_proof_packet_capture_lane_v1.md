# First-Week Proof Packet Capture Lane v1

## Scope

Local-only deterministic capture-lane extension on `main`. This adds a
`first_week` packet to the existing fast real-text screen-review lane. No
learner-facing UI, copy, routing, telemetry, curriculum progress, or product
behavior changed.

## Command

```bash
./tools/screen_review_fast_v1.sh first_week compact
```

Output:

- `output/screen_review/current/first_week_fast/`
- `output/screen_review/current/first_week_fast/contact_sheet.png`
- `output/screen_review/current/first_week_fast/screen_review_first_week_fast.zip`
- `output/screen_review/current/first_week_fast/manifest.json`

## PIEC result

Existing deterministic entries already covered:

- placement intro: `placement`;
- W1 decision: `runnerDrill`;
- first correct feedback: `runnerFirstCorrectFeedback`;
- first wrong feedback: `runnerFirstWrongFeedback`;
- Review repair handoff: `firstWeekReview`;
- Profile progress proof: `firstWeekProfile`.

Existing product states without direct screenshot coverage were exposed through
the existing deterministic seams only:

- Welcome micro-win decision, feedback, and handoff are captured by pumping the
  existing `welcome` entry and driving the real Welcome CTA / answer / continue
  interaction inside the Flutter test renderer.
- Repair focus, Repair result, and Session repair are captured by new
  debug-only direct entries that seed the existing same-signal repair intent
  from `actions_legal_context` into `actions_check_drill`, then select real
  repair options through the existing feedback/result/session copy seams.

## Captured states

The first-week packet writes these local-only PNGs:

- `compact.placement.png`
- `compact.welcome_decision.png`
- `compact.welcome_feedback.png`
- `compact.welcome_handoff.png`
- `compact.decision.png`
- `compact.correct_feedback.png`
- `compact.wrong_feedback.png`
- `compact.repair_focus.png`
- `compact.repair_result.png`
- `compact.session_repair.png`
- `compact.review_handoff.png`
- `compact.profile_return.png`

## Remaining limitations

- Placement capture shows the intro state, not a completed placement result.
- Profile capture shows the existing first-week progress proof. It is not a
  deterministic dynamic repair-return-reason fixture.
- `repair_focus` and `session_repair` both use the existing same-signal repair
  miss path; the session summary is visible inside the feedback receipt seam
  because the current product presents repair result and session repair
  together.
- Generated PNG, JSON, README, and ZIP outputs remain local-only and must not
  be committed.

## Files changed

- `tools/screen_review_fast_v1.sh`
- `tools/act0_real_text_surface_capture_v1.dart`
- `tools/package_screen_review_v1.py`
- `lib/ui_v2/app_root.dart`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- `docs/_reviews/first_week_proof_packet_capture_lane_v1.md`

## Checks

- Red contract check failed before implementation because the new repair proof
  debug entries were absent.
- Targeted capture contract tests passed after implementation.
- `./tools/screen_review_fast_v1.sh first_week compact` passed and produced the
  first-week packet.
- Formatting, shell syntax, Python compile, analyzer, and diff checks are run
  as part of this lane validation.

## Recommendation

Use `first_week compact` as the proof-packet lane before broad visual or
commercial review. If release review needs a completed placement-result shot or
a dynamic Profile return-reason shot, scope those as a separate narrow capture
extension rather than product work.
