# Wave 2.2 - Premium Surface Hierarchy Review

Date: 2026-06-26
Base: `origin/main` at `f320577b91445290c27746a092692d66205fcfc3`
Verdict: `wave2_2_premium_surface_hierarchy_ready`

## Mission

Make the first beta repair loop read as one calm premium story:

`Home repair CTA -> Practice/current fix -> repair result/Fix landed -> Session Summary close -> Review/Profile proof`

This wave stayed inside active Act0 hierarchy and copy rhythm. It did not change route semantics, queue resolution, progression state, telemetry, content models, paywalls, AI/persona surfaces, Modern Table, or durable repair history.

## Files Changed

- `lib/ui_v2/act0_shell/act0_play_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- `test/ui_v2/act0_play_shell_v1_test.dart`
- `test/ui_v2/act0_session_summary_earned_moment_v1_test.dart`
- `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- `docs/_reviews/wave2_2_premium_surface_hierarchy_v1.md`

## Implementation Summary

- Practice now promotes a launchable active repair queue above the daily hero, so a current fix from Home stays the first actionable Practice surface.
- Passive saved repair rows keep their existing secondary placement behind the daily hero.
- The promoted repair queue now labels the section `Current fix first` with support copy `Run this repair before extra reps.`
- Session Summary now places `What next` immediately after the proof hero/unlock area and before supporting proof cards.
- Existing Session Summary proof, earned moment, repair receipt, CTA behavior, and callbacks remain unchanged.
- A nearby detached-shell preview test was adjusted away from a stale exact headline assertion and back to structural summary coverage; copy-specific assertions stay in the focused Session Summary suite.

## Claim Safety

No new visible claims were added for AI, GTO, solver output, leak fixed forever, mastery, clearing, rating, radar, all-time history, level-as-proof, badges, premium pricing, or paywall pressure.

The wave uses existing accepted repair language around current fixes and session proof. It does not claim queue resolution or durable historical repair completion.

## Boundary Notes

- No active route entry points were changed.
- No queue state, launch target, repair outcome, achievement seed, telemetry, or progression contract was changed.
- No Review clearing behavior was changed.
- No Profile data model or durable all-time proof was changed.
- `docs/_reviews/current_agent_context_v1.md` was requested by the prompt but is not present in this checkout.

## Validation

Focused red checks first failed for the intended hierarchy mismatches:

- `flutter test test/ui_v2/act0_play_shell_v1_test.dart --name "Practice repair queue shows CTA only for launchable active row"`
- `flutter test test/ui_v2/act0_session_summary_earned_moment_v1_test.dart --name "Session Summary hero leads with correct read and good fix proof"`

Final checks passed:

- `dart format lib/ui_v2/act0_shell/act0_play_shell_v1.dart lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart test/ui_v2/act0_play_shell_v1_test.dart test/ui_v2/act0_session_summary_earned_moment_v1_test.dart`
- `dart format test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- `flutter test test/ui_v2/act0_play_shell_v1_test.dart`
- `flutter test test/ui_v2/act0_session_summary_earned_moment_v1_test.dart`
- `flutter test test/ui_v2/act0_play_shell_v1_test.dart test/ui_v2/act0_session_summary_earned_moment_v1_test.dart`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name "Canonical detached shell shows block completion summary and continues in-node|Practice keeps unseen daily and topic reps locked until the route clears them"`
- `flutter analyze`
- `git diff --check`
- `graphify hook-check`

## Screenshot Proof

Ran:

`./tools/screen_review_fast_v1.sh day2_return compact`

Result: passed. Contact sheet inspected at:

`output/screen_review/current/day2_return_fast/contact_sheet.png`

Generated screen-review output remains untracked.

## Caveats

The screen-review contact sheet covers the active return repair surfaces, not every possible Practice queue state. The hierarchy-sensitive Practice and Session Summary states are covered by focused widget tests.

## Next Recommendation

Run the next beta wave against Review/Profile proof continuity only if user-visible proof still feels fragmented after the current Practice and Session Summary hierarchy lands.
