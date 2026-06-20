# Practice Repair-Reinforcement Entry v1

## Branch / Base Commit

- Branch: `codex/act0-surface-coherence-map-v1`
- Base commit: `744dfe32`
- Mode: local-only implementation wave; no push, PR, or GitHub action.

## Files Changed

- `lib/ui_v2/act0_shell/act0_play_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- `test/ui_v2/act0_play_shell_v1_test.dart`
- `test/ui_v2/act0_repair_intent_resolver_v1_test.dart`
- `docs/_reviews/practice_repair_reinforcement_entry_v1.md`

## Seam Used

Practice now consumes the existing Act0 Practice recommendation seam:

- `Act0ShellPreviewScreenV1._practiceSurfaceRecommendation`
- existing next-useful-hand receipt derivation
- existing repair-intent target / exact-replay selection
- existing `Act0PlayShellV1` recommended group, title, subtitle, reason, outcome, and mastery fields

No new route, repair owner, persistence, telemetry owner, or payload contract was added.

## Repair / Fragile Practice Behavior

When an open repair intent resolves to a mapped same-clue target, Practice promotes the `weak_spots` group into the primary featured entry even when daily practice is also available.

The learner-facing entry uses:

- `Practice the no-bet-yet clue`
- `One same-clue rep will help lock this in.`
- `Repair reinforcement`

This keeps Practice focused on fast reinforcement instead of becoming Review or a dashboard.

## Exact Replay Behavior

When the deterministic repair target falls back to exact replay, Practice uses replay-only wording:

- `Replay this spot`
- `Train the exact spot again.`

It does not claim same-signal transfer, broader skill improvement, solver truth, or guaranteed improvement.

## No-Repair Fallback

When no open repair intent exists, existing daily/generic Practice behavior remains the fallback. Daily remains the featured training entry, and the compact repair-empty state remains secondary.

## Role-Boundary Preservation

- Home still owns the top-level next action.
- Practice reinforces the existing next useful hand.
- Review, Learn, and You/Profile implementations were not changed.
- Session proof and summary ceremony copy do not render inside Practice.

## Pills / Chips Handling

The repair reinforcement entry is a featured block/card. The repair reason is a compact label on the block, not a primary pill/chip. Existing tertiary Practice metadata chips remain unchanged.

## Copy Safety

No new AI, adaptive, ML, GTO, solver, optimal, win-rate, guarantee, premium, paywall, trial, unlock, leak-detected, or forever-mastery language was added.

The existing weak-spot CTA fallback was changed from `Fix next leak` to `Practice repair` so the repair-reinforcement path avoids unsafe leak wording.

## Telemetry Safety

No telemetry event names, sinks, payload fields, or ownership changed. Existing telemetry tests remain the guard.

## Screenshot Review

Verdict: approved before PR.

- Mapped repair: `/Users/elmarsalimzade/Sharky_1.0/output/playwright/practice_repair_reinforcement_entry_v1/browser_practice_widget_dark_20260620_022109/compact_phone.practice_mapped_repair.png`
- Exact replay: `/Users/elmarsalimzade/Sharky_1.0/output/playwright/practice_repair_reinforcement_entry_v1/browser_practice_widget_dark_20260620_022109/compact_phone.practice_exact_replay.png`
- No-repair fallback: `/Users/elmarsalimzade/Sharky_1.0/output/playwright/practice_repair_reinforcement_entry_v1/browser_practice_widget_dark_20260620_022109/compact_phone.practice_no_repair.png`
- Supplemental full-app fallback: `/Users/elmarsalimzade/Sharky_1.0/output/playwright/practice_repair_reinforcement_entry_v1/browser_full_app_fallback_en2_20260620_022344/compact_phone.practice_no_repair_full_app.png`

Screenshots are local-only artifacts and are not committed. The primary Practice entry is block/card based, not a primary pill/chip. No Session proof, session ceremony, Home card, or Review dashboard leaked into Practice.

## Checks

- `flutter test test/ui_v2/act0_play_shell_v1_test.dart --reporter expanded`: passed, `+8`
- `flutter test test/ui_v2/act0_repair_intent_resolver_v1_test.dart --reporter expanded`: passed, `+17`
- `flutter test test/ui_v2/act0_repair_intent_copy_guard_v1_test.dart --reporter expanded`: passed, `+10`
- `flutter test test/ui_v2/act0_telemetry_sink_v1_test.dart --reporter expanded`: passed, `+13`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --reporter expanded`: passed, `+656`
- `flutter analyze`: passed
- `git diff --check`: passed
- `./tools/fast_loop_world1_v1.sh`: passed, `FAST LOOP PASS`, `+666`

## Exact Next Wave Recommendation

Act0 Review Repair-Coach Entry v1: after Practice reinforces the immediate repair hand, Review can more safely tighten repeated-clue coaching without becoming a raw error log or analytics dashboard.
