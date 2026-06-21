# Retention / Habit Loop Expansion v1

- Branch: `codex/act0-learn-route-clarity-v1`
- Mode: local-only bounded product implementation

## PIEC

- Home already had a repair-based return-reason seam through `nextUsefulHandReasonLine` and `_homeNextUsefulHandReasonLine(...)`.
- Review already had the repair coach support line through `_Act0NextUsefulHandCopyBridgeV1` and the Review repair coach card.
- Practice already had a featured repair-reinforcement entry, but its eyebrow reason was generic: `Repair reinforcement`.
- The existing deterministic repair receipt provided the needed learner-facing source data through `_Act0NextUsefulHandReasonReceiptV1.missedSignalLabel`.

## Change

- Practice now uses the existing repair receipt to show a specific return reason:
  - `[Signal] is still the clue to stabilize.`
- The copy stays calm, short, English-first, and table-signal specific.
- No streak pressure, reminders, notifications, XP economy, dashboard, AI, solver, premium, or guilt mechanics were added.

## Surfaces

- Home: existing repair-based next useful hand reason retained.
- Review: existing repair coach reason retained.
- Practice: featured repair reinforcement now explains the active missed signal.

## Files changed

- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- `test/ui_v2/act0_repair_intent_resolver_v1_test.dart`
- `docs/_reviews/retention_habit_loop_expansion_v1.md`

## Checks

- Red test:
  - `flutter test test/ui_v2/act0_repair_intent_resolver_v1_test.dart --plain-name "mapped repair reason becomes Practice reinforcement entry"`
  - Failed before implementation because Practice still showed the generic `Repair reinforcement` label.
- Targeted tests:
  - `flutter test test/ui_v2/act0_repair_intent_resolver_v1_test.dart test/ui_v2/act0_result_feedback_rhythm_surface_v1_test.dart test/ui_v2/act0_repair_intent_lifecycle_v1_test.dart test/ui_v2/act0_repair_intent_copy_guard_v1_test.dart`
- Analyze:
  - `flutter analyze`
- Visible copy/surface proof:
  - `./tools/screen_review_fast_v1.sh core compact`
  - Output: `output/screen_review/current/core_fast/contact_sheet.png`
- Whitespace:
  - `git diff --check`

## Next step

- Package this local wave for PR when ready.
