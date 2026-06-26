# Wave 2.8 - Sharky Soul / Compact Coach Layer v1

## 1. Verdict

wave2_8_sharky_soul_compact_coach_layer_ready

## 2. TOP1 matrix row target

Primary row:

- Sharky mascot / emotional layer

Secondary rows:

- Session Summary payoff
- Review/Profile trust
- first proof loop
- habit loop / return reason

## 3. Wave goal and scope

Goal: add a compact, governed Sharky coach/soul layer to selected Act0 first proof-loop moments without creating an AI coach, chat persona, mascot animation system, reward system, or broad character feature.

Scope stayed inside deterministic presentation/copy seams: a tiny phrase contract plus one compact line in Practice current fix, Review active repair, and Session Summary proof. Existing route, launch, repair, Review, Profile, progression, telemetry, and model behavior were not changed.

## 4. Files changed

- `lib/ui_v2/act0_shell/act0_sharky_coach_phrase_contract_v1.dart`
- `lib/ui_v2/act0_shell/act0_play_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_review_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- `test/ui_v2/act0_sharky_coach_phrase_contract_v1_test.dart`
- `test/ui_v2/act0_play_shell_v1_test.dart`
- `test/ui_v2/act0_review_shell_v1_test.dart`
- `test/ui_v2/act0_session_summary_earned_moment_v1_test.dart`
- `docs/_reviews/wave2_8_sharky_soul_compact_coach_layer_v1.md`

## 5. Sharky phrase contract / phrase set added or reused

Added `Act0SharkyCoachMomentV1` and `act0SharkyCoachLineForMomentV1` as a small deterministic phrase contract.

Current governed phrase set:

- Home active repair: `One clue at a time.`
- Practice current fix: `Run it once more while the clue is fresh.`
- Review active repair: `This is the spot to clean up.`
- Repair result proof: `Good. You saw the table this time.`
- Session Summary proof: `Small win, real proof.`

The contract test proves the lines are ASCII-only, short, unique, and free of forbidden claim families.

## 6. Surface-by-surface Sharky moments

Practice current fix:

- Adds one compact line under the promoted `Current fix first` queue support text.
- Renders only when the primary repair queue contains a launchable active repair target.

Review active repair:

- Adds one compact line inside the existing `What to fix next` card, above the Wave 2.7.1 `Practice this spot` CTA.
- Keeps the CTA visible and route-owned by the existing `onFixMistake` callback.

Session Summary proof:

- Uses the existing `Act0SharkyPresenceBubbleV1` treatment in the `What next` proof card.
- If authored `summary.sharkyLine` exists, it still wins.
- If no authored line exists, `Small win, real proof.` appears only when the proof hero exists.
- No Sharky proof line appears in the no-proof gate-first summary state.

Home and repair-result runner:

- Existing Sharky identity/feedback treatments were left intact to avoid duplicate density.
- The phrase contract includes home and repair-result lines for governed future use, but this wave did not force extra visible blocks into already-supported states.

## 7. Why each Sharky line supports proof/payoff rather than decoration

- `Run it once more while the clue is fresh.` supports the active Practice target and reinforces one short rep.
- `This is the spot to clean up.` makes the Review bridge feel coached while keeping the table clue and CTA dominant.
- `Small win, real proof.` supports the Session Summary close as an emotional receipt without claiming durable mastery.

Each line is table-signal adjacent, short, and secondary to the existing proof copy and CTA.

## 8. Claim-safety proof

No new visible language introduces AI, GTO, solver, mastery, permanent leak fix, fixed forever, cleared, resolved, recovered, all-time analytics, rating, radar, level, premium/paywall value, guaranteed improvement, or win-rate improvement claims.

Focused tests cover:

- phrase-contract forbidden copy;
- Practice queue forbidden copy remains absent;
- Review active repair forbidden copy remains absent;
- Session Summary proof/fallback behavior remains claim-safe.

## 9. No route/progression/model/telemetry boundary proof

No changes were made to:

- route families or canonical Act0 entry;
- progression;
- telemetry;
- data models or durable evidence contracts;
- repair queue resolution or removal;
- Review clearing;
- durable all-time history;
- Profile evidence;
- Modern Table;
- premium/paywall;
- AI/persona/chat systems.

The only logic added is deterministic phrase selection for already-rendered proof-loop surfaces.

## 10. Review CTA bridge preservation proof

The Wave 2.7.1 `Practice this spot` CTA remains in `_ReviewRepairCoachCardV1` and still calls `onFixMistake(mistake)`.

Focused tests passed:

- `Review keeps one compact active repair note without a Home redirect`
- `Review practice CTA uses existing active repair callback`
- `Debug capture review Practice CTA launches existing repair task`

## 11. Tests and validation run

RED checks first failed for missing contract/lines:

- `flutter test test/ui_v2/act0_sharky_coach_phrase_contract_v1_test.dart`
- `flutter test test/ui_v2/act0_play_shell_v1_test.dart --name "Practice repair queue shows CTA only for launchable active row"`
- `flutter test test/ui_v2/act0_review_shell_v1_test.dart --name "Review keeps one compact active repair note without a Home redirect|Review practice CTA uses existing active repair callback"`
- `flutter test test/ui_v2/act0_session_summary_earned_moment_v1_test.dart --name "Session Summary hero leads with correct read and good fix proof|Session Summary hero can lead with good fix proof only|Session Summary keeps gate-first hero without proof"`

GREEN validation:

- `flutter test test/ui_v2/act0_sharky_coach_phrase_contract_v1_test.dart`
- `flutter test test/ui_v2/act0_play_shell_v1_test.dart`
- `flutter test test/ui_v2/act0_review_shell_v1_test.dart`
- `flutter test test/ui_v2/act0_session_summary_earned_moment_v1_test.dart`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name "Debug Day 2 proof surfaces expose open repair return story|Debug capture review entry keeps active repair as compact context|Debug capture review Practice CTA launches existing repair task"`
- `dart format --set-exit-if-changed` on touched Dart/test files
- `flutter analyze`
- `git diff --check`
- `git diff --cached --check`
- `graphify hook-check`
- `git status --short`

## 12. Screenshot proof run and result

- `./tools/screen_review_fast_v1.sh day2_return compact`
  - Result: passed.
  - Local packet: `output/screen_review/current/day2_return_fast/contact_sheet.png`
  - Local zip: `output/screen_review/current/day2_return_fast/screen_review_day2_return_fast.zip`
- `./tools/screen_review_fast_v1.sh first_week compact`
  - Result: passed.
  - Local packet: `output/screen_review/current/first_week_fast/contact_sheet.png`
  - Local zip: `output/screen_review/current/first_week_fast/screen_review_first_week_fast.zip`

`full_scroll compact` was not run because this was a narrow compact-copy layer, not a broad shell layout or full-scroll proof change.

## 13. Generated/untracked artifact status

Generated outputs remain local-only and untracked:

- `output/claude_review/`
- `output/screen_review/`

No generated screenshots, zips, or output directories are included in the commit.

## 14. Expected TOP1 matrix movement

- Sharky mascot / emotional layer: `6.8-7.6` -> `7.2-7.9`
- Session Summary payoff: `8.2-8.8` -> `8.3-8.9`
- Review/Profile trust: Review trust gets a small lift from coached active repair handoff; Profile unchanged by design.
- first proof loop: `8.8-9.2` -> `8.9-9.3`

## 15. Caveats

- This is not a full Sharky character system.
- The phrase contract includes two governed future-use moments that are not newly rendered everywhere in this wave.
- The compact lines are intentionally quiet; they should be judged as emotional support, not as the primary proof text.

## 16. Next recommendation

Proceed to Wave 2.9 - Earned Rewards / Achievement Hooks v1 only if the refreshed packets still read calm and proof-led. Keep any reward work tied to local proof and avoid badge art, level/radar/rating proof, or fake mastery claims.
