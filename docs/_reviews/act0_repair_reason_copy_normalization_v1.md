# Act0 Repair Reason Copy Normalization v1

Date: 2026-06-19
Branch: `codex/act0-repair-reason-copy-normalization-v1`
Base commit: `8448693`
Mode: tiny product-quality follow-up

## 1. Files Inspected

- `lib/ui_v2/act0_shell/act0_home_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- `lib/ui_v2/act0_shell/act0_repair_intent_copy_guard_v1.dart`
- `test/ui_v2/act0_repair_intent_copy_guard_v1_test.dart`
- `test/ui_v2/act0_repair_intent_resolver_v1_test.dart`

## 2. Files Changed

- `lib/ui_v2/act0_shell/act0_repair_intent_copy_guard_v1.dart`
- `test/ui_v2/act0_repair_intent_copy_guard_v1_test.dart`
- `test/ui_v2/act0_repair_intent_resolver_v1_test.dart`
- `docs/_reviews/act0_repair_reason_copy_normalization_v1.md`

## 3. Copy Labels Normalized

The visible repair copy now normalizes the current `No bet yet` clue before it
is inserted into learner-facing sentences.

- Same-signal phrase: `that nobody has bet yet`
- Exact replay phrase: `the no-bet-yet clue`

Unknown labels still degrade deterministically into a compact lower-case clue
phrase instead of exposing title-case internal labels directly.

## 4. Same-Signal Before / After

Before:

`You missed No bet yet. This hand repairs the same clue.`

After:

`You missed that nobody has bet yet. This hand repeats that table clue.`

## 5. Exact-Replay Before / After

Before:

`Replay this spot to fix No bet yet.`

After:

`Replay this spot to fix the no-bet-yet clue.`

## 6. Scope Safety

No new route, UI redesign, Modern Table work, table geometry change, Repair
Result Receipt, Session Summary, telemetry change, commerce change, workflow
change, generated output, or `external_competitors/` change was added.

## 7. Copy Safety

The copy still renders only through `act0RepairIntentCopyGuardLineV1(...)`.
Forbidden AI/adaptive/GTO/solver/premium/paywall/trial/unlock/win-rate/guarantee
terms remain covered by targeted tests.

## 8. Tests / Checks Run

TDD red:

- `flutter test test/ui_v2/act0_repair_intent_copy_guard_v1_test.dart test/ui_v2/act0_repair_intent_resolver_v1_test.dart --reporter expanded`
  failed because production still rendered the old `No bet yet` sentences.

Focused green:

- `dart format lib/ui_v2/act0_shell/act0_repair_intent_copy_guard_v1.dart test/ui_v2/act0_repair_intent_copy_guard_v1_test.dart test/ui_v2/act0_repair_intent_resolver_v1_test.dart`
- `flutter test test/ui_v2/act0_repair_intent_copy_guard_v1_test.dart test/ui_v2/act0_repair_intent_resolver_v1_test.dart --reporter expanded`

Final verification:

- `flutter analyze`: passed.
- `git diff --check`: passed.
- `./tools/fast_loop_world1_v1.sh`: passed, FAST LOOP PASS.
- `./tools/release_gate_world1.sh`: passed, World1 release gate passed.

## 9. PR Readiness Verdict

Ready for PR.

## 10. Exact Next Wave

`Repair Result Receipt v1`
