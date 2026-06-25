# Onboarding Handoff Simplification v1

## 1. Verdict

onboarding_handoff_simplification_ready

## 2. Wave 2 scope finding addressed

Addressed the Wave 2 finding that the accepted onboarding/start handoff was functional but visually busy. The busy state came from stacking an answer/check/first-hand progress row, a result focus chip row, and a second first-hand preview card before the bottom CTA.

## 3. Onboarding/handoff owner map

- `lib/ui_v2/act0_shell/act0_placement_shell_v1.dart` owns placement intake, diagnostic-ready copy, placement result handoff, and the result action bar.
- `lib/ui_v2/act0_shell/act0_welcome_shell_v1.dart` owns the post-demo welcome handoff before Home.
- `test/ui_v2/act0_shell_preview_screen_v1_test.dart` owns focused preview assertions for first-run placement, placement result handoff, welcome completion, CTA routing, forbidden copy, and compact handoff chip behavior.

## 4. Implemented hierarchy/copy changes

- Removed the placement-result `Answer / Quick check / First hand` launch path row.
- Removed the placement-result secondary preview card with `Beginner-safe` and `Fold, check, call, raise` chips.
- Replaced result-derived chip clutter with one short proof row: `Fast start`, `First hand ready`, plus one level-specific short label.
- Simplified the welcome handoff promise to `Your first useful hand is ready.`
- Removed the welcome handoff proof block that repeated `Read / Answer / Reason / Move on`.

## 5. CTA ownership proof

The placement result still uses `act0_shell_placement_start_recommended` as the primary `FilledButton` with the existing `onStartRecommended` callback. The secondary `act0_shell_placement_start_zero` remains an `OutlinedButton` with the existing `onStartFromZero` callback.

The welcome handoff still uses the existing `act0_shell_welcome_primary_cta` button and `widget.onCompleted` callback. No CTA callback or route target was changed.

## 6. Preserved onboarding truths

- `Fast start, no exam.` remains in the placement intro.
- `No exam. Just your starting point.` remains in the placement intro proof card.
- `Answer two quick questions. Then Sharky opens the first useful hand.` remains in the placement hero.
- `Three short checks before your first hand.` and `Three short checks, then your first hand is ready.` remain in the diagnostic-ready handoff.
- `Your path is ready.` remains the welcome payoff headline.

## 7. Route/progression truth proof

The focused placement result test still taps `act0_shell_placement_start_recommended`, completes the welcome layer, and reaches `act0_shell_runner_screen`. The welcome completion test still verifies Home handoff and stored progress preservation.

No route state, progression model, placement question list, placement scoring, telemetry sink, content model, or tab behavior was changed.

## 8. Forbidden-claim proof

The updated tests continue to assert no `Premium trial`, `Preview 7-day trial`, or premium teaser copy on the placement handoff. The implementation added no AI/chat/persona, mastery/leak/GTO/solver, paywall, trial, or generated-screenshot code.

## 9. Screenshot/capture proof

Generated locally only:

- `output/screen_review/current/first_week_fast/contact_sheet.png`
- `output/screen_review/current/first_week_fast/screen_review_first_week_fast.zip`
- `output/screen_review/current/day2_return_fast/contact_sheet.png`
- `output/screen_review/current/day2_return_fast/screen_review_day2_return_fast.zip`
- `output/screen_review/current/full_scroll_fast/contact_sheet.png`
- `output/screen_review/current/full_scroll_fast/screen_review_full_scroll_fast.zip`

Generated output directories are intentionally untracked and must not be committed.

## 10. Tests / validation

Passed:

- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name "Placement diagnostic sends the recommended start through Welcome"`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name "First-run placement asks questions before the app shell"`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name "Welcome completes one local micro win before Home handoff"`
- `flutter test test/ui_v2/onboarding_welcome_screen_compact_contract_test.dart`
- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh day2_return compact`
- `./tools/screen_review_fast_v1.sh full_scroll compact`
- `graphify hook-check`
- `flutter analyze`

Known unrelated validation note:

- Existing Russian localization atom tests fail because placement/welcome atom fallback strings such as `Route check` are still English under the current test host. This was present outside the handoff hierarchy change and was not modified in this wave.

## 11. Next recommended wave

Review Compact Honest Shell.
