# Visible Repair Reason Surface v1

- Branch: `codex/act0-learn-route-clarity-v1`
- Mode: local-only bounded product implementation
- Product scope: active Act0 wrong-answer / repair feedback surface

## PIEC result

- Existing repair reason data already lived in `Act0RepairIntentV1` and the next-useful-hand receipt/copy bridge:
  - missed signal: `missedSignalId`, `missedSignalLabel`
  - selected repair target: `targetWorldId`, `targetLessonId`, `targetTaskId`
  - reason: `reasonCode` plus guarded bridge copy via `_Act0NextUsefulHandCopyBridgeV1`
- The missing seam was presentation: immediate feedback had signal proof and repair receipts, but no compact learner-facing repair reason block.

## Change

- Added a compact `Repair focus` block to `Act0FeedbackShellV1` when a wrong/suboptimal feedback state has repair reason data and signal proof.
- The block shows:
  - missed table signal;
  - why the next useful hand was selected;
  - next decision focus.
- Wired the active Act0 preview flow to pass the existing next-useful-hand repair reason line into feedback.

## Not changed

- No telemetry fields or owners changed.
- No route changes.
- No Modern Table changes.
- No AI, chat, ML, solver, GTO, optimal, premium, paywall, or monetization copy.
- No broad content expansion or dashboard surface.

## Checks

- `flutter test test/ui_v2/act0_result_feedback_rhythm_surface_v1_test.dart` passed.
- `flutter test test/ui_v2/act0_repair_intent_lifecycle_v1_test.dart` passed.
- `flutter test test/ui_v2/act0_result_feedback_rhythm_surface_v1_test.dart test/ui_v2/act0_repair_intent_lifecycle_v1_test.dart test/ui_v2/act0_repair_intent_resolver_v1_test.dart test/ui_v2/act0_repair_intent_copy_guard_v1_test.dart` passed.
- `./tools/screen_review_fast_v1.sh core compact` passed.
- Fast screen review output: `output/screen_review/current/core_fast/contact_sheet.png`.
- `dart format` passed on touched Dart files.
- `flutter analyze` passed.
- `git diff --check` passed.
